<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class SetUpdateTokenCommand extends Command
{
    protected static $defaultName = "instances:set-update-token";
    protected static $defaultDescription =
        "<fg=red>!NEEDS SUDO PRIVILEGES!</> This command sets an update token for all instances"
    ;

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
            ->setAliases(["sut"])
            ->addOption("token", "t", InputOption::VALUE_REQUIRED, "Update token as string")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
            ->addOption("autoyes", "a", InputOption::VALUE_NONE, "Auto answer questions with yes")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->posix->isSudo()) {
            $this->writer->error(
                $output,
                "Please execute this script as sudo user!"
            );
            return Command::FAILURE;
        }

        $token = $input->getOption("token");

        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        $path = "/usr/local/share/doil/instances";
        $suffix = "global";
        if (! $input->getOption("global")) {
            $path = "$home_dir/.doil/instances";
            $suffix = "local";
        }

        $instances = $this->filesystem->getFilesInPath($path);
        if (count($instances) == 0) {
            $this->writer->error(
                $output,
                "No instances found!",
                "Use <fg=gray>doil instances:ls --help</> for more information."
            );
            return Command::FAILURE;
        }

        if (! $input->getOption("autoyes")) {
            $question = new ConfirmationQuestion(
                "This will also update 'update_token' in your doil config. Want to continue? [yN]: ",
                false
            );

            $helper = $this->getHelper("question");
            if (!$helper->ask($input, $output, $question)) {
                $output->writeln("Abort by user!");
                return Command::FAILURE;
            }
        }


        $this->filesystem->replaceLineInFile("/etc/doil/doil.conf", "/update_token=.*/", "update_token=" . $token);

        foreach ($instances as $i) {
            $started = $this->startInstance($output, $path, $i);
            sleep(3);
            $this->applyUpdateToken($output, $i . "." . $suffix, $token);
            $this->docker->commit($i . "_" . $suffix);
            if ($started) {
                $this->stopInstance($output, $path, $i);
            }
        }
        return Command::SUCCESS;
    }

    protected function startInstance(OutputInterface $output, string $path, string $instance) : bool
    {
        if (! $this->hasDockerComposeFile($path . "/" . $instance, $output)) {
            throw new InvalidArgumentException("Can't find a suitable docker-compose.yml file in $path/$instance");
        }

        if (! $this->docker->isInstanceUp($path . "/" . $instance)) {
            $this->writer->beginBlock($output, "Start instance $instance");
            $this->docker->startContainerByDockerCompose($path . "/" . $instance);
            $this->writer->endBlock();
            return true;
        }

        return false;
    }

    protected function stopInstance(OutputInterface $output, string $path, string $instance) : string
    {
        if ($this->docker->isInstanceUp($path . "/" . $instance)) {
            $this->writer->beginBlock($output, "Stop instance $instance");
            $this->docker->stopContainerByDockerCompose($path . "/" . $instance);
            $this->writer->endBlock();
        }

        return $instance;
    }

    protected function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        if ($this->filesystem->exists($path . "/docker-compose.yml")) {
            return true;
        }

        $output->writeln("<fg=red>Error:</>");
        $output->writeln("\tCan't find a suitable docker-compose file in this directory '$path'.");
        $output->writeln("\tIs this the right directory?");
        $output->writeln("\tSupported filenames: docker-compose.yml");

        return false;
    }

    protected function applyUpdateToken(OutputInterface $output, string $salt_key, string $token): void
    {
        $this->writer->beginBlock($output, "Apply update token to $salt_key");
        $this->docker->setGrain($salt_key, "update_token", $token);
        $this->docker->refreshGrains($salt_key);
        $this->docker->applyState($salt_key, "set-update-token");
        $this->docker->applyState($salt_key, "ilias-update-hook");
        $this->docker->commit($salt_key);
        $this->writer->endBlock();
    }
}