<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class StatusCommand extends Command
{
    use CLIHelper;

    protected static $defaultName = "instances:status";
    protected static $defaultDescription = "This command lists all running instances.";

    protected Docker $docker;

    public function __construct(Docker $docker)
    {
        parent::__construct();

        $this->docker = $docker;
    }

    public function configure() : void
    {
        $this->setAliases(["status"]);
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $doil_instances = $this->docker->ps();
        $doil_instances = array_filter($doil_instances, function($a) {
            if (
                strstr($a, "CONTAINER ID") ||
                strstr($a, "doil") ||
                strstr($a, "doil_saltmain") ||
                strstr($a, "_local") ||
                strstr($a, "_global")
            ) {
                return true;
            }

            return false;
        });

        foreach ($doil_instances as $instance) {
            $output->writeln($instance);
        }

        return Command::SUCCESS;
    }
}