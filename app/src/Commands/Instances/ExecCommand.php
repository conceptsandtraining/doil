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
    name: 'instances:exec|exec',
    description: 'This command lets you execute a command inside a running docker instance.'
)]
class ExecCommand extends Command
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
            ->addArgument("instance", InputArgument::REQUIRED, "name of the instance")
            ->addArgument("cmd", InputArgument::REQUIRED, "command to execute inside instance")
            ->addOption("working-dir", "w", InputOption::VALUE_OPTIONAL, "determines the working directory inside the instance")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $cmd = $input->getArgument("cmd");
        $working_dir = $input->getOption("working-dir");

        $path = "/usr/local/share/doil/instances/$instance";
        $name = $instance . "_global";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = "$home_dir/.doil/instances/$instance";
            $name = $instance . "_local";
        }

        if ($this->hasDockerComposeFile($path, $output)) {
            if (! $this->docker->isInstanceUp($path)) {
                $this->docker->startContainerByDockerCompose($path);
            }
            $this->docker->executeBashCommandInsideContainer($name, $working_dir, $cmd);
            return Command::SUCCESS;
        }

        return Command::FAILURE;
    }

    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        if (file_exists($path . "/docker-compose.yml")) {
            return true;
        }

        $this->writer->error(
            $output,
            "Instance not found!",
            "Use <fg=gray>doil instances:list</> to see current installed instances."
        );

        return false;
    }
}