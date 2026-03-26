<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Office;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class DownCommand extends Command
{
    protected const OFFICE_PATH = "/usr/local/lib/doil/server/office";

    protected static $defaultName = "office:down";
    protected static $defaultDescription = "Stops the office server";

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
            $output->writeln("Nothing to do. Office is already down.");
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Stop office");
        $this->docker->stopContainerByDockerCompose(self::OFFICE_PATH);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}