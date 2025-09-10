<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Pack;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Commands\Repo\Repo;
use CaT\Doil\Lib\ILIAS\IliasInfo;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;

class ExportCommand extends Command
{
    protected static $defaultName = "pack:export";
    protected static $defaultDescription =
        "Exports an instance to an archive with all the data needed for an import."
        . " The final archive name will be <instance>-doilpack.zip.";

    protected Docker $docker;
    protected Posix $posix;
    protected Filesystem $filesystem;
    protected Writer $writer;
    protected ProjectConfig $project_config;
    protected Git $git;
    protected RepoManager $repo_manager;
    protected IliasInfo $ilias_info;

    public function __construct(
        Docker $docker,
        Posix $posix,
        Filesystem $filesystem,
        Writer $writer,
        ProjectConfig $project_config,
        Git $git,
        RepoManager $repo_manager,
        IliasInfo $ilias_info
    ) {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->writer = $writer;
        $this->project_config = $project_config;
        $this->git = $git;
        $this->repo_manager = $repo_manager;
        $this->ilias_info = $ilias_info;
    }

    public function configure() : void
    {
        $this
            ->addArgument("instance", InputArgument::REQUIRED, "Name of the instance to export")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the instance is global")
            ->addOption("cron", "c", InputOption::VALUE_NONE, "Must be used for triggering export by cron")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $name = $instance . "-doilpack";
        $starting = false;

        $check = $this->checkName();
        $check($instance);

        $path = "/usr/local/share/doil/instances/$instance";
        $suffix = "global";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = "$home_dir/.doil/instances/$instance";
            $suffix = "local";
        }

        if ($this->filesystem->exists($name . ".zip")) {
            if (! $this->confirmOverwriting($input, $output, $name)) {
                return Command::FAILURE;
            }
        }

        if (! $this->hasDockerComposeFile($path, $output)) {
            return Command::FAILURE;
        }

        if (! $this->docker->isInstanceUp($path)) {
            $this->writer->beginBlock($output, "Starting instance $instance");
            $this->docker->startContainerByDockerCompose($path);
            $starting = true;
            sleep(5);
            $this->writer->endBlock();
        }

        $this->writer->beginBlock($output, "Building zip file for " . $instance . "_" . $suffix);

        $this->writer->beginBlock($output, "Exporting database");
        if ($input->getOption("cron")) {
            $this->docker->executeNoTTYCommand(
                $path,
                $instance,
                "bash",
                "-c",
                "mysqldump ilias > /var/ilias/data/ilias.sql"
            );
        } else {
            $this->docker->executeCommand(
                $path,
                $instance,
                "bash",
                "-c",
                "mysqldump ilias > /var/ilias/data/ilias.sql"
            );
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Exporting data");
        $this->filesystem->remove($name);
        $this->filesystem->makeDirectoryRecursive($name . "/var/www/html/Customizing/global");
        $this->filesystem->makeDirectoryRecursive($name . "/var/www/html/.git");
        $this->filesystem->makeDirectoryRecursive($name . "/conf");

        $idea_paths = $this->filesystem->find_dirs($path, ".idea", 3);
        if (count($idea_paths) > 0) {
            $idea_path = $idea_paths[0];
            $idea_base_path = substr($idea_path, strlen($path));
            $this->filesystem->makeDirectoryRecursive($name . "/conf" . $idea_base_path);
            $this->filesystem->copyDirectory($idea_path, $name . "/conf" . $idea_base_path);
        }

        $this->docker->copy($instance . "_" . $suffix, "/var/ilias", $name . "/var/");
        $this->docker->copy($instance . "_" . $suffix, "/var/www/html/.git/config", $name . "/var/www/html/.git/config");
        if ($this->ilias_info->getIliasVersion($path) >= 10) {
            $this->filesystem->makeDirectoryRecursive($name . "/var/www/html/public");
            $this->docker->copy($instance . "_" . $suffix, "/var/www/html/public/data", $name . "/var/www/html/public");
        } else {
            $this->docker->copy($instance . "_" . $suffix, "/var/www/html/data", $name . "/var/www/html");
        }

        if ($this->filesystem->exists($path . "/volumes/ilias/Customizing/global/skin")) {
            $this->docker->copy($instance . "_" . $suffix, "/var/www/html/Customizing/global/skin", $name . "/var/www/html/Customizing/global");
        }
        $this->docker->copy($instance . "_" . $suffix, "/var/www/html/ilias.ini.php", $name . "/var/www/html/");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Exporting config");
        $this->exportProjectConfig($output, $path, $name . "/conf/project_config.json", $instance . "_" . $suffix);
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Create zip file");
        $this->filesystem->zip($name);
        $this->filesystem->remove($name);
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Cleanup");
        $this->docker->executeCommand(
            $path,
            $instance,
            "bash",
            "-c",
            "rm /var/ilias/data/ilias.sql"
        );
        $this->writer->endBlock();

        if ($starting) {
            $this->writer->beginBlock($output, "Stopping instance $instance");
            $this->docker->stopContainerByDockerCompose($path);
            $this->writer->endBlock();
        }

        $this->writer->endBlock();

        return Command::SUCCESS;
    }

    protected function confirmOverwriting(InputInterface $input, OutputInterface $output, string $name) : bool
    {
        $helper = $this->getHelper('question');
        $question = new ConfirmationQuestion("The file '$name.zip' already exist, do you want to overwrite it [yN]: ", false);
        if (! $helper->ask($input, $output, $question)) {
            $output->writeln("Abort by user!");
            return false;
        }
        return true;
    }

    protected function checkName() : Closure
    {
        return function(string $name) {
            if ("" == $name) {
                throw new RuntimeException("Name of the instance cannot be empty!");
            }
            if (! preg_match("/^[a-zA-Z0-9_]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only letters and numbers are allowed!");
            }

            return $name;
        };
    }

    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        if (file_exists($path . "/docker-compose.yml")) {
            return true;
        }

        $this->writer->error(
            $output,
            "Can't find a suitable docker-compose file in this directory '$path'.",
            "Is this the right directory?\n\tSupported filenames: docker-compose.yml"
        );

        return false;
    }

    protected function exportProjectConfig(OutputInterface $output, string $path, string $target_path, string $instance) : int
    {
        $project_config = $this->filesystem->readFromJsonFile($path . "/conf/project_config.json");
        $project_config = array_shift($project_config);

        $branch = $this->git->getCurrentBranch($path . "/volumes/ilias");

        $cmd = "php -v | head -n 1 | cut -d ' ' -f2 | cut -d . -f1,2";
        $php_version = trim($this->docker->executeDockerCommandWithReturn($instance, $cmd));

        $remotes = $this->git->getRemotes($path . "/volumes/ilias");

        if (count($remotes) == 0) {
            $this->writer->error(
                $output,
                "Can't find a suitable remote inside directory '$path/volumes/ilias'."
            );
            return self::FAILURE;
        }

        $repo = false;
        if (count($remotes) == 1) {
            $key = array_key_first($remotes);
            $repo = new Repo($key, $remotes[$key]);
        }

        if (count($remotes) > 1) {
            $remotes = array_filter($remotes, function ($url) use ($branch, $path) {
                return $this->git->isBranchInRepo($path . "/volumes/ilias", $url, $branch);
            });

            if (count($remotes) == 0) {
                $this->writer->error(
                    $output,
                    "Can't find branch '$branch' inside the available remotes inside directory '$path/volumes/ilias'."
                );
                return self::FAILURE;
            }

            $repos = [];
            foreach ($remotes as $name => $url) {
                $repos[] = new Repo($name, $url);
            }

            $local_repos = array_filter($repos, function(Repo $repo) {
                return $this->repo_manager->repoUrlExists($repo);
            });

            $global_repos = array_filter($repos, function(Repo $repo) {
                $repo = $repo->withIsGlobal(true);
                return $this->repo_manager->repoUrlExists($repo);
            });

            $local_cat_ilias_repos = [];
            if (count($local_repos) > 0) {
                $local_cat_ilias_repos = array_filter($local_repos, function(Repo $local_repo) {
                    return strstr($local_repo->getUrl(), "conceptsandtraining") || strstr($local_repo->getUrl(), "ILIAS-eLearning");
                });
            }

            $global_cat_ilias_repos = [];
            if (count($global_repos) > 0) {
                $global_cat_ilias_repos = array_filter($global_repos, function(Repo $local_repo) {
                    return strstr($local_repo->getUrl(), "conceptsandtraining") || strstr($local_repo->getUrl(), "ILIAS-eLearning");
                });
            }

            $found = false;
            if (count($local_cat_ilias_repos) > 0) {
                $repo = array_shift($local_cat_ilias_repos);
                $found = true;
            }

            if (!$found && count($global_cat_ilias_repos) > 0) {
                $repo = array_shift($global_cat_ilias_repos);
                $found = true;
            }

            if (!$found && count($local_repos)) {
                $repo = array_shift($local_repos);
                $found = true;
            }

            if (!$found && count($global_repos)) {
                $repo = array_shift($global_repos);
                $found = true;
            }

            if (!$found && count($repos) > 0) {
                $repo = array_shift($repos);
            }
        }

        $project_config = $project_config
            ->withRepositoryBranch($branch)
            ->withPhpVersion($php_version)
            ->withRepositoryName($repo->getName())
            ->withRepositoryUrl($repo->getUrl())
        ;

        $this->filesystem->saveToJsonFile($target_path, [$project_config]);

        return self::SUCCESS;
    }
}