<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LoginCommand extends Command
{
    protected static $defaultName = "instances:login";
    protected static $defaultDescription =
        "This command lets you log into the running docker container " .
        "of your ILIAS instance. If [instance] not given " .
        "doil will try to login the instance from the current active " .
        "directory if doil can find a suitable configuration."
    ;

    protected Docker $docker;
    protected Posix $posix;
    protected Filesystem $filesystem;

    public function __construct(Docker $docker, Posix $posix, Filesystem $filesystem)
    {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
    }

    public function configure() : void
    {
        $this
            ->setAliases(["login"])
            ->addArgument("instance", InputArgument::OPTIONAL, "name of the instance to start")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");

        if (is_null($instance)) {
            $path = $this->filesystem->getCurrentWorkingDirectory();

            if ($this->hasDockerComposeFile($path, $output)) {
                $name = $this->filesystem->getFilenameFromPath($path);
                if (! $this->docker->isInstanceUp($path)) {
                    $this->docker->startContainerByDockerCompose($path);
                }
                $this->docker->loginIntoContainer($path, $name);
                return Command::SUCCESS;
            }

            return Command::FAILURE;
        }

        $path = "/usr/local/share/doil/instances/$instance";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = "$home_dir/.doil/instances/$instance";
        }

        if ($this->hasDockerComposeFile($path, $output)) {
            if (! $this->docker->isInstanceUp($path)) {
                $this->docker->startContainerByDockerCompose($path);
            }
            $this->docker->loginIntoContainer($path, $instance);
            return Command::SUCCESS;
        }

        return Command::FAILURE;
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