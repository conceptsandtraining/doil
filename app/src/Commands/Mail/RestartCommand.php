<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Mail;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class RestartCommand extends Command
{
    protected const MAIL_PATH = "/usr/local/lib/doil/server/mail";

    protected static $defaultName = "mail:restart";
    protected static $defaultDescription = "Restarts the mail server";

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
        if (! $this->docker->isInstanceUp(self::MAIL_PATH)) {
            $this->docker->startContainerByDockerCompose(self::MAIL_PATH);
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Restart mail server");
        $this->docker->stopContainerByDockerCompose(self::MAIL_PATH);
        $this->docker->startContainerByDockerCompose(self::MAIL_PATH);
        sleep(3);
        $this->docker->executeDockerCommand(
            "doil_mail",
            "supervisorctl start startup"
        );
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}