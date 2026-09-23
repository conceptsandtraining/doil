<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'salt:down',
    description: "Deletes a repository."
)]
class DownCommand extends Command
{
    protected const SALT_PATH = "/usr/local/lib/doil/server/salt";

    public function __construct(
        protected Docker $docker,
        protected Writer $writer
    ) {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::SALT_PATH)) {
            $output->writeln("Nothing to do. Salt is already down.");
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Stop salt main");
        $this->docker->stopContainerByDockerCompose(self::SALT_PATH);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}