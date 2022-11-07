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

class PathCommand extends Command
{
    protected static $defaultName = "instances:path";
    protected static $defaultDescription = "Shows the root folder of the desired instance.";

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
            ->setAliases(["path"])
            ->addArgument("instance", InputArgument::OPTIONAL, "name of the instance to start")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");

        if (is_null($instance)) {
            $this->writer->error(
                $output,
                "Please specify an instance in order to get the path."
            );

            return Command::FAILURE;
        }

        $path = "/usr/local/share/doil/instances/$instance";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = "$home_dir/.doil/instances/$instance";
        }

        if ($this->filesystem->exists($path)) {
            $output->writeln("<fg=gray>" . $this->filesystem->readLink($path) . "</>");
            return Command::SUCCESS;
        }

        $this->writer->error(
            $output,
            "Instance not found!",
            "Use <fg=gray>doil instances:list</> to see current installed instances."
        );

        return Command::FAILURE;
    }
}