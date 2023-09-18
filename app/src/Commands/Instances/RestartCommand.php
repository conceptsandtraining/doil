<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class RestartCommand extends Command
{
    protected static $defaultName = "instances:restart";
    protected static $defaultDescription =
        "This command restarts an instance. If [instance] not given doil will try to restart the instance" .
        " from the current active directory if doil can find a suitable configuration."
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
            ->setAliases(["restart"])
            ->addArgument("instance", InputArgument::OPTIONAL, "Name of the instance to start")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
            ->addOption("all", "a", InputOption::VALUE_NONE, "If is set start all instances")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $all = $input->getOption("all");

        if (is_null($instance) && ! $all) {
            $path = $this->filesystem->getCurrentWorkingDirectory();

            return $this->restartInstance(
                $output,
                $path,
                $this->filesystem->getFilenameFromPath($path)
            );
        }


        $path = "/usr/local/share/doil/instances";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = "$home_dir/.doil/instances";
        }

        if ($all) {
            $instances = $this->filesystem->getFilesInPath($path);
            if (count($instances) == 0) {
                $this->writer->error(
                    $output,
                    "No instances found!",
                    "Use <fg=gray>doil instances:ls --help</> for more information."
                );
                return Command::FAILURE;
            }

            foreach ($instances as $i) {
                if ($this->docker->isInstanceUp($path . "/" . $i)) {
                    $this->restartInstance($output, $path . "/" . $i, $i);
                }
            }
            return Command::SUCCESS;
        }

        return $this->restartInstance($output, $path . "/" . $instance, $instance);
    }

    protected function restartInstance(OutputInterface $output, string $path, string $instance) : int
    {
        if (! $this->hasDockerComposeFile($path, $output)) {
            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Restart instance $instance");

        if ($this->docker->isInstanceUp($path)) {
            $this->docker->stopContainerByDockerCompose($path);
        }
        $this->docker->startContainerByDockerCompose($path);

        $this->writer->endBlock();

        return Command::SUCCESS;
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
}