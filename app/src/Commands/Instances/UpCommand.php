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
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'instances:up|up',
    description: "This command starts an instance. If [instance] not given doil will try to start the instance" .
    " from the current active directory if doil can find a suitable configuration."
)]
class UpCommand extends Command
{
    public function __construct(
        protected Docker $docker,
        protected Posix $posix,
        protected Filesystem $filesystem,
        protected Writer $writer
    ) {
        parent::__construct();
    }

    public function configure() : void
    {
        $this
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

            return $this->startInstance(
                $output,
                $path,
                $this->filesystem->getFilenameFromPath($path)
            );
        }

        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        $path = "/usr/local/share/doil/instances";
        if (! $input->getOption("global")) {
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
                $this->startInstance($output, $path . "/" . $i, $i);
            }
            return Command::SUCCESS;
        }

        return $this->startInstance($output, $path . "/" . $instance, $instance);
    }

    protected function startInstance(OutputInterface $output, string $path, string $instance) : int
    {
        if (! $this->hasDockerComposeFile($path, $output)) {
            return Command::FAILURE;
        }

        if (! $this->docker->isInstanceUp($path)) {
            $this->writer->beginBlock($output, "Start instance $instance");
            $this->docker->startContainerByDockerCompose($path);
            $this->writer->endBlock();
            return Command::SUCCESS;
        }

        $output->writeln("Nothing to do. Instance $instance is already up.");

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