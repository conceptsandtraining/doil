<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Office;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class RestartCommand extends Command
{
    protected const OFFICE_PATH = "/usr/local/lib/doil/server/office";

    protected static $defaultName = "office:restart";
    protected static $defaultDescription = "Restarts the office server";

    protected Docker $docker;
    protected Writer $writer;

    public function __construct(Docker $docker, Writer $writer)
    {
        parent::__construct();

        $this->docker = $docker;
        $this->writer = $writer;
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::OFFICE_PATH)) {
            $this->docker->startContainerByDockerCompose(self::OFFICE_PATH);
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Restart office");
        $this->docker->stopContainerByDockerCompose(self::OFFICE_PATH);
        $this->docker->startContainerByDockerCompose(self::OFFICE_PATH);
        sleep(3);
        $instances = array_filter($this->docker->getRunningInstanceNames());
        foreach ($instances as $instance) {
            if ($instance == "doil_office") {
                continue;
            }
            if (
                strpos($instance, 'doil_') != false ||
                strpos($instance, '_local') != false ||
                strpos($instance, '_global') != false
            ) {
                try {
                    $this->docker->executeDockerCommand(
                        $instance,
                        "supervisorctl start startup 2>&1 >/dev/null"
                    );
                } catch (\Exception $e) {
                }
            }
        }
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}