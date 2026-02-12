<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Mail;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'mail:change-password',
    description: "<fg=red>!NEEDS SUDO PRIVILEGES!</> Change the roundcube password."
)]
class ChangePasswordCommand extends Command
{
    protected const MAIL_PATH = "/usr/local/lib/doil/server/mail";

    public function __construct(
        protected Docker $docker,
        protected Writer $writer,
        protected Posix $posix
    ) {
        parent::__construct();
    }

    public function configure() : void
    {
        $this
            ->addArgument("password", InputArgument::REQUIRED, "password to be set for roundcube")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->posix->isSudo()) {
            $this->writer->error(
                $output,
                "Please execute this script as sudo user!"
            );
            return Command::FAILURE;
        }

        if (! $this->docker->isInstanceUp(self::MAIL_PATH)) {
            $this->docker->startContainerByDockerCompose(self::MAIL_PATH);
        }

        $password = $input->getArgument("password");
        $hash = $this->docker->getShadowHashForInstance("doil.mail", $password);
        $hash = $this->escapeDollarChar($hash);
        $this->docker->setGrain("doil.mail", "roundcube_password", $hash);
        sleep(1);

        $this->writer->beginBlock($output, "Apply state change-roundcube-password to doil_mail");
        $this->docker->applyState("doil.mail", "change-roundcube-password");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Apply changes to image");
        $this->docker->commit("doil_mail", "doil_mail");
        $this->writer->endBlock();

        return Command::SUCCESS;
    }

    protected function escapeDollarChar(string $subject) : string
    {
        return str_replace('$', '\$', $subject);
    }
}