<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LoginCommand extends Command
{
    protected const SALT_PATH = "/usr/local/lib/doil/server/salt";

    protected static $defaultName = "salt:login";
    protected static $defaultDescription = "Login into the salt main server";

    protected Docker $docker;

    public function __construct(Docker $docker)
    {
        parent::__construct();

        $this->docker = $docker;
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::SALT_PATH)) {
            $this->docker->startContainerByDockerCompose(self::SALT_PATH);
        }

        $this->docker->loginIntoContainer(self::SALT_PATH, "doil_saltmain");
        return Command::SUCCESS;
    }
}