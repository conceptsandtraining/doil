<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Proxy;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'proxy:login',
    description: "Login into the proxy server."
)]
class LoginCommand extends Command
{
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";

    public function __construct(
        protected Docker $docker
    ) {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::PROXY_PATH)) {
            $this->docker->startContainerByDockerCompose(self::PROXY_PATH);
        }

        $this->docker->loginIntoContainer(self::PROXY_PATH, "doil_proxy");
        return Command::SUCCESS;
    }
}