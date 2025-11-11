<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'instances:status|status',
    description: 'This command lists all running instances.'
)]
class StatusCommand extends Command
{
    public function __construct(protected Docker $docker)
    {
        parent::__construct();
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $doil_instances = $this->docker->ps();
        $doil_instances = array_filter($doil_instances, function($a) {
            if (
                strstr($a, "CONTAINER ID") ||
                strstr($a, "doil_mail") ||
                strstr($a, "doil_proxy") ||
                strstr($a, "doil_salt") ||
                strstr($a, "doil_keycloak") ||
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