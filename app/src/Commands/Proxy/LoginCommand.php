<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Proxy;

use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LoginCommand extends Command
{
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";

    protected static $defaultName = "proxy:login";
    protected static $defaultDescription = "Login into the proxy server";

    protected Docker $docker;

    public function __construct(Docker $docker)
    {
        parent::__construct();

        $this->docker = $docker;
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