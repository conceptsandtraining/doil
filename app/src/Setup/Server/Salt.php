<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Salt
{
    use SymfonyShell;

    /**
     * @throws ProcessFailedException
     */
    public function start(LoggerInterface $logger) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            "/usr/local/lib/doil/server/salt/docker-compose.yml",
            "up",
            "-d"
        ];

        $logger->info("Start instance");
        $this->run($cmd, $logger);
    }

    /**
     * @throws ProcessFailedException
     */
    public function commit(LoggerInterface $logger) : void
    {
        $cmd = [
            "docker",
            "commit",
            "doil_salt",
            "doil_salt:stable"
        ];

        $logger->info("Start instance");
        $this->run($cmd, $logger);
    }
}