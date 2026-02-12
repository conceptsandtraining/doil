<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Mail;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'mail:down',
    description: "Stops the mail server."
)]
class DownCommand extends Command
{
    protected const MAIL_PATH = "/usr/local/lib/doil/server/mail";
    public function __construct(
        protected Docker $docker,
        protected Writer $writer
    ) {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::MAIL_PATH)) {
            $output->writeln("Nothing to do. Mail is already down.");
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Stop mail server");
        $this->docker->stopContainerByDockerCompose(self::MAIL_PATH);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}