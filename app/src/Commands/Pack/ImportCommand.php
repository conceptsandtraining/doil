<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Pack;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Filesystem\Exception\FileNotFoundException;

class ImportCommand extends Command
{
    protected static $defaultName = "pack:import";
    protected static $defaultDescription =
        "With this command doil is able to import an archive of doilpack into an ILIAS installation. " .
        "If the installation is not present, it will be created with the properties of the configuration " .
        "inside of the pack. If the instance is present all existing data will be overwritten by the new data."
    ;

    protected Docker $docker;
    protected Posix $posix;
    protected Filesystem $filesystem;
    protected RepoManager $repo_manager;
    protected Writer $writer;

    public function __construct(
        Docker $docker,
        Posix $posix,
        Filesystem $filesystem,
        RepoManager $repo_manager,
        Writer $writer
    ) {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->repo_manager = $repo_manager;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this
            ->addArgument("instance", InputArgument::REQUIRED, "Name of the new or updated instance")
            ->addArgument("package", InputArgument::REQUIRED, "Name of the package to import")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the instance is global")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $package = $input->getArgument("package");
        $create = false;

        $check = $this->checkName();
        $check($instance);
        $check = $this->checkPackage();
        $check($package);

        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        $path = "$home_dir/.doil/instances/$instance";
        $suffix = "local";
        $flag = "";
        if ($input->getOption("global")) {
            $path = "/usr/local/share/doil/instances/$instance";
            $suffix = "global";
            $flag = " -g";
        }

        $output->writeln("Importing instance $instance");

        if (! $this->filesystem->exists($path)) {
            if (! $this->confirmCreateNewInstance($input, $output, $instance)) {
                $output->writeln("Import aborted!");
                return Command::FAILURE;
            }
            $create = true;
        }

        $dir = $this->filesystem->getDirFromPath($package);
        $target = $this->filesystem->getFilenameFromPath($package);
        $this->filesystem->unzip($package, $target);
        $unpacked = $dir . DIRECTORY_SEPARATOR . $target;
        $delete_path = $unpacked;

        if ($create) {
            // This is very ugly, but necessary for importing old doil export zips.
            $sql_dump = "";
            if ($this->filesystem->exists($unpacked . "/conf/project_config.json")) {
                $project_config = $this->filesystem->readFromJsonFile($unpacked . "/conf/project_config.json");
                $project_config = array_shift($project_config);
            } else if ($this->filesystem->exists("$unpacked/$target/conf/doil.conf")) {
                $unpacked = $unpacked . DIRECTORY_SEPARATOR . $target;
                $project_config = $this->readOldProjectConfig("$unpacked/conf/doil.conf");
                $sql_dump = $unpacked . DIRECTORY_SEPARATOR . "var/ilias/ilias.sql";
            } else if ($this->filesystem->exists("$unpacked/conf/doil.conf")) {
                $project_config = $this->readOldProjectConfig("$unpacked/conf/doil.conf");
                $sql_dump = $unpacked . DIRECTORY_SEPARATOR . "var/ilias/ilias.sql";
            } else {
                throw new FileNotFoundException("Can not found doil config file in package.");
            }

            $repo = $this->repo_manager->getEmptyRepo();
            $repo = $repo
                ->withName($instance . "_import")
                ->withUrl($project_config->getRepositoryUrl())
            ;

            $existing_repo = null;
            if ($this->repo_manager->repoUrlExists($repo)) {
                $existing_repo = $this->repo_manager->getLocalRepoByUrl($repo->getUrl());
            } else {
                $repo = $repo->withIsGlobal(true);
                if ($this->repo_manager->repoUrlExists($repo)) {
                    $existing_repo = $this->repo_manager->getGlobalRepoByUrl($repo->getUrl());
                }
            }

            if (! is_null($existing_repo)) {
                $repo = $existing_repo;
            } else {
                if ($this->repo_manager->repoNameExists($repo)) {
                    $this->writer->error(
                        $output,
                        "Repository with name '{$repo->getName()}' already exists!",
                        "Use <fg=gray>doil repo:list</> to see current installed repos"
                    );

                    return Command::FAILURE;
                }

                $this->repo_manager->addRepo($repo);
            }

            $create_command = $this->getApplication()->find('instances:create');
            $args = [
                '-n' => true,
                '--name' => $instance,
                '--repo' => $repo->getName(),
                '--branch' => $project_config->getRepositoryBranch(),
                '--phpversion' => $project_config->getPhpVersion(),
                '--global' => $input->getOption("global")
            ];

            if ($repo->isGlobal()) {
                $args += ["--use-global-repo" => true];
            }

            $create_input = new ArrayInput($args);
            $create_command->run($create_input, $output);
        }

        if ($this->docker->isInstanceUp($path)) {
            $this->docker->stopContainerByDockerCompose($path);
        }

        $this->writer->beginBlock($output, "Copying necessary files");

        if ($create) {
            $this->filesystem->copy($unpacked . "/var/www/html/ilias.ini.php", $path . "/volumes/ilias/ilias.ini.php");
        } else {
            $this->filesystem->copy($path . "/volumes/data/ilias-config.json", "/tmp/ilias-config.json");
        }
        $this->filesystem->copyDirectory($unpacked . "/var/www/html/data", $path . "/volumes/ilias/data");
        $this->filesystem->copyDirectory($unpacked . "/var/ilias/data", $path . "/volumes/data");
        if (! $create) {
            $this->filesystem->copy("/tmp/ilias-config.json", $path . "/volumes/data/ilias-config.json");
        }
        if ($sql_dump != "") {
            $this->filesystem->copy($sql_dump, $path . "/volumes/data/ilias.sql");
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Importing database");
        if (! $this->docker->isInstanceUp($path)) {
            $this->docker->startContainerByDockerCompose($path);
            sleep(30);
        }

        if ($this->filesystem->exists($path . "/README.md")) {
            $mysql_password = $this->filesystem->grepMysqlPasswordFromFile($path . "/README.md");
        } else {
            $mysql_password = $this->askForMysqlPassword($input, $output);
        }
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "mysql -e 'DROP DATABASE IF EXISTS ilias;'"
        );
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "mysql -e 'CREATE DATABASE ilias;'"
        );
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "mysql ilias < /var/ilias/data/ilias.sql"
        );

        $location = $this->filesystem->searchForFileRecursive($path . "/volumes/ilias/data", "/client\.ini\.php/");

        if (is_null($location)) {
            $this->writer->error(
                $output,
                "Something went wrong. Client ini not found!"
            );
            return Command::FAILURE;
        }

        $this->filesystem->replaceLineInFile($location, "/^pass =.*/", "pass = \"" . $mysql_password . "\"");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Apply ilias config");
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "php /var/www/html/setup/setup.php update /var/ilias/data/ilias-config.json -y"
        );
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Setting permissions");
        $this->docker->stopContainerByDockerCompose($path);
        $this->docker->startContainerByDockerCompose($path);
        sleep(15);
        $this->docker->applyState($instance . "." . $suffix, "access");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Finalizing docker image");
        $this->docker->commit($instance . "_" . $suffix);
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Cleanup");
        $this->filesystem->remove($delete_path);
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "rm /var/ilias/data/ilias.sql"
        );
        $this->docker->stopContainerByDockerCompose($path);
        $this->writer->endBlock();

        $output->writeln("Please start the imported instance by <fg=gray>doil up $instance $flag</>.");

        return Command::SUCCESS;
    }

    protected function checkName() : Closure
    {
        return function(string $name) {
            if ("" == $name) {
                throw new RuntimeException("Name of the instance cannot be empty!");
            }
            if (! preg_match("/^[a-z0-9_]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only lowercase letters, numbers and underscores are allowed!");
            }

            return $name;
        };
    }

    protected function checkPackage() : Closure
    {
        return function(string $package) {
            if (! $this->filesystem->exists($package)) {
                throw new RuntimeException("The package $package does not exists!");
            }

            return $package;
        };
    }

    protected function confirmCreateNewInstance(InputInterface $input, OutputInterface $output, string $instance) : bool
    {
        $helper = $this->getHelper("question");
        $question = new ConfirmationQuestion("Instance $instance does not exist. Do you want to create it? [Yn]: ", true);

        return $helper->ask($input, $output, $question);
    }

    protected function askForMysqlPassword(InputInterface $input, OutputInterface $output) : string
    {
        $helper = $this->getHelper('question');
        $question = new Question('Please enter a new MySQL password: ');
        $question->setNormalizer(function($v) { return $v ? trim($v) : ''; });
        $question->setValidator($this->checkName());
        return $helper->ask($input, $output, $question);
    }

    protected function readOldProjectConfig(string $path) : ProjectConfig
    {
        $project_name = explode("\"", $this->filesystem->getLineInFile($path, "PROJECT_NAME"));
        $project_repository = explode("\"", $this->filesystem->getLineInFile($path, "PROJECT_REPOSITORY"));
        $project_repository_url = explode("\"", $this->filesystem->getLineInFile($path, "PROJECT_REPOSITORY_URL"));
        $project_branch = explode("\"", $this->filesystem->getLineInFile($path, "PROJECT_BRANCH"));
        $project_php_version = explode("\"", $this->filesystem->getLineInFile($path, "PROJECT_PHP_VERSION"));

        return new ProjectConfig(
            $project_name[1],
            $project_repository[1],
            $project_branch[1],
            $project_repository_url[1],
            $project_php_version[1]
        );
    }
}