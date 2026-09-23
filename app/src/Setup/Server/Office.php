<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Office
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
            "/usr/local/lib/doil/server/office/docker-compose.yml",
            "up",
            "-d"
        ];

        $logger->info("Start instance");
        $this->run($cmd, $logger);

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_office",
            "bash",
            "-c",
            "grep -qxF '172.24.0.254    doil' /etc/hosts || echo '172.24.0.254    doil' >> /etc/hosts"
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
            "doil_office",
            "doil_office:stable"
        ];

        $logger->info("Start instance");
        $this->run($cmd, $logger);
    }
}