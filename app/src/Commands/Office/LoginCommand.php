<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Office;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LoginCommand extends Command
{
    protected const OFFICE_PATH = "/usr/local/lib/doil/server/office";

    protected static $defaultName = "office:login";
    protected static $defaultDescription = "Login into the office server";

    protected Docker $docker;

    public function __construct(Docker $docker)
    {
        parent::__construct();

        $this->docker = $docker;
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::OFFICE_PATH)) {
            $this->docker->startContainerByDockerCompose(self::OFFICE_PATH);
        }

        $this->docker->loginIntoContainer(self::OFFICE_PATH, "doil_office");
        return Command::SUCCESS;
    }
}