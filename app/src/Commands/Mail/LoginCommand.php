<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Mail;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'mail:login',
    description: "Login into the mail server."
)]
class LoginCommand extends Command
{
    protected const MAIL_PATH = "/usr/local/lib/doil/server/mail";

    public function __construct(protected Docker $docker)
    {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::MAIL_PATH)) {
            $this->docker->startContainerByDockerCompose(self::MAIL_PATH);
        }

        $this->docker->loginIntoContainer(self::MAIL_PATH, "doil_mail");
        return Command::SUCCESS;
    }
}