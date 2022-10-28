<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class PruneCommand extends Command
{
    protected const SALT_PATH = "/usr/local/lib/doil/server/salt";

    protected static $defaultName = "salt:prune";
    protected static $defaultDescription = "Delete all registered minion keys. This could be helpful for debugging purposes. A restart of salt forces the keys to be regenerated.";

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
        if (! $this->docker->isInstanceUp(self::SALT_PATH)) {
            $this->docker->startContainerByDockerCompose(self::SALT_PATH);
        }

        $this->writer->beginBlock($output, "Prune salt main");
        $this->docker->executeCommand(self::SALT_PATH, "doil_saltmain", "salt-key", "-y", "-D");
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}