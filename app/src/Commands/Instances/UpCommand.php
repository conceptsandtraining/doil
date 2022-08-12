<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class UpCommand extends Command
{
    use CLIHelper;

    protected static $defaultName = "instances:up";
    protected static $defaultDescription =
        "This command starts an instance. If [instance] not given doil will try to start the instance" .
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
            ->setAliases(["up"])
            ->addArgument("instance", InputArgument::OPTIONAL, "Name of the instance to start")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");

        if (is_null($instance)) {
            $path = $this->filesystem->getCurrentWorkingDirectory();

            if (! $this->hasDockerComposeFile($path, $output)) {
                return Command::FAILURE;
            }

            $instance = $this->filesystem->getFilenameFromPath($path);
            if (! $this->docker->isInstanceUp($path)) {
                $this->writer->beginBlock($output, "Start container $instance");
                $this->docker->startContainerByDockerCompose($path);
                $this->writer->endBlock();
                return Command::SUCCESS;
            }

            $output->writeln("Nothing to do. Instance $instance is already up.");

            return Command::SUCCESS;
        }

        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        $path = "$home_dir/.doil/instances/$instance";
        if ($input->getOption("global")) {
            $path = "/usr/local/share/doil/instances/$instance";
        }

        if (! $this->hasDockerComposeFile($path, $output)) {
            return Command::FAILURE;
        }

        if (! $this->docker->isInstanceUp($path)) {
            $this->writer->beginBlock($output, "Start container $instance");
            $this->docker->startContainerByDockerCompose($path);
            $this->writer->endBlock();
            return Command::SUCCESS;
        }

        $output->writeln("Nothing to do. Instance $instance is already up.");

        return Command::SUCCESS;
    }
}