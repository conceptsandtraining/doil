<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'salt:login',
    description: "Login into the salt main server."
)]
class LoginCommand extends Command
{
    protected const SALT_PATH = "/usr/local/lib/doil/server/salt";

    public function __construct(protected Docker $docker)
    {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::SALT_PATH)) {
            $this->docker->startContainerByDockerCompose(self::SALT_PATH);
        }

        $this->docker->loginIntoContainer(self::SALT_PATH, "doil_salt");
        return Command::SUCCESS;
    }
}