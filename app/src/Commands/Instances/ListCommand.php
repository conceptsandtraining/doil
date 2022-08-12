<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ListCommand extends Command
{
    use CLIHelper;

    protected static $defaultName = "instances:list";
    protected static $defaultDescription = "Lists all created instances.";


    protected Posix $posix;
    protected Filesystem $filesystem;
    protected Writer $writer;

    public function __construct(Posix $posix, Filesystem $filesystem, Writer $writer)
    {
        parent::__construct();

        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this->setAliases(["ls"]);
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $output->writeln("Currently registered local instances:");
        $local_instances_dir = $this->posix->getHomeDirectory($this->posix->getUserId()) . "/.doil/instances";
        if (!$this->filesystem->exists($local_instances_dir)) {
            $this->writer->error(
                $output,
                "Directory '$local_instances_dir' doesn't exist. Please check your 'doil' installation."
            );
            return Command::FAILURE;
        }

        foreach ($this->filesystem->getFilesInPath($local_instances_dir) as $file) {
            $output->writeln($file);
        }

        $output->writeln("");

        $output->writeln("Currently registered global instances:");
        $global_instances_dir = "/usr/local/share/doil/instances";
        if (!$this->filesystem->exists($global_instances_dir)) {
            $this->writer->error(
                $output,
                "Directory '$global_instances_dir' doesn't exist. Please check your 'doil' installation."
            );
            return Command::FAILURE;
        }
        foreach ($this->filesystem->getFilesInPath($global_instances_dir) as $file) {
            $output->writeln($file);
        }

        return Command::SUCCESS;
    }
}