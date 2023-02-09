<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Pack;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Question\Question;
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

    public function __construct(Docker $docker, Posix $posix, Filesystem $filesystem, Writer $writer)
    {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this
            ->addArgument("instance", InputArgument::REQUIRED, "Name of the instance to export")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the instance is global")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $name = $instance . "-doilpack";

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

        $this->writer->beginBlock($output, "Building zip file for " . $instance . "_" . $suffix);

        if (! $this->docker->isInstanceUp($path)) {
            $this->docker->startContainerByDockerCompose($path);
        }

        $this->writer->beginBlock($output, "Exporting database");
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
            "mysqldump --user=root --password=$mysql_password ilias > /var/ilias/data/ilias.sql"
        );
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Exporting data");

        $this->filesystem->remove($name);
        $this->filesystem->makeDirectoryRecursive($name . "/var/www/html");
        $this->filesystem->makeDirectoryRecursive($name . "/conf");

        $this->docker->copy($instance . "_" . $suffix, "/var/ilias", $name . "/var/");
        $this->docker->copy($instance . "_" . $suffix, "/var/www/html/data", $name . "/var/www/html");
        $this->docker->copy($instance . "_" . $suffix, "/var/www/html/ilias.ini.php", $name . "/var/www/html/");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Exporting config");
        $this->filesystem->copy($path . "/conf/project_config.json", $name . "/conf/project_config.json");
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
            if (! preg_match("/^[a-zA-Z0-9]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only letters and numbers are allowed!");
            }

            return $name;
        };
    }

    protected function askForMysqlPassword(InputInterface $input, OutputInterface $output) : string
    {
        $helper = $this->getHelper('question');
        $question = new Question('Please enter a new MySQL password: ');
        $question->setNormalizer(function($v) { return $v ? trim($v) : ''; });
        $question->setValidator($this->checkName());
        return $helper->ask($input, $output, $question);
    }

    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        if (file_exists($path . "/docker-compose.yml")) {
            return true;
        }

        $output->writeln("<fg=red>Error:</>");
        $output->writeln("\tCan't find a suitable docker-compose file in this directory '$path'.");
        $output->writeln("\tIs this the right directory?");
        $output->writeln("\tSupported filenames: docker-compose.yml");

        return false;
    }
}