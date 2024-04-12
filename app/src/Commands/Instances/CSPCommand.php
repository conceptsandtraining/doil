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
use Symfony\Component\Console\Exception\InvalidArgumentException;

class CSPCommand extends Command
{
    protected static $defaultName = "instances:csp";
    protected static $defaultDescription =
        "This command sets CSP rules for the given instance or all instances"
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
            ->setAliases(["csp"])
            ->addArgument("instance", InputArgument::OPTIONAL, "Name of the instance to set csp for")
            ->addOption("rules", "r", InputOption::VALUE_REQUIRED, "CSP rules as string")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
            ->addOption("all", "a", InputOption::VALUE_NONE, "If flag is set, apply CSP rules to ALL instances")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $all = $input->getOption("all");
        $rules = $input->getOption("rules");

        if (is_null($instance) && ! $all) {
            throw new InvalidArgumentException("Not enough arguments (missing: \"instance\" or \"all\")");
        }

        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        $path = "/usr/local/share/doil/instances";
        $suffix = ".global";
        if (! $input->getOption("global")) {
            $path = "$home_dir/.doil/instances";
            $suffix = ".local";
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
                if ($i == "ilias7") {
                    continue;
                }
                $started = $this->startInstance($output, $path, $i);
                sleep(3);
                $this->applyCSP($output, $i . $suffix, $rules);
                if ($started) {
                    $this->stopInstance($output, $path, $i);
                }
            }
            return Command::SUCCESS;
        }

        $started = $this->startInstance($output, $path, $instance);
        sleep(3);
        $this->applyCSP($output, $instance . $suffix, $rules);
        if ($started) {
            $this->stopInstance($output, $path, $instance);
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

    protected function applyCSP(OutputInterface $output, string $salt_key, $rules)
    {
        $this->writer->beginBlock($output, "Apply csp rules to $salt_key");
        $this->docker->setGrain($salt_key, "csp", $rules);
        $this->docker->applyState($salt_key, "apache");
        $this->writer->endBlock();
    }
}