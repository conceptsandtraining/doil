<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Proxy
{
    use SymfonyShell;

    public function __construct(
        protected Filesystem $filesystem
    ) {}

    /**
     * @throws ProcessFailedException
     */
    public function start(LoggerInterface $logger, string $host) : void
    {
        $this->filesystem->replaceStringInFile(
            "/usr/local/lib/doil/server/proxy/conf/nginx/local.conf",
            "%TPL_SERVER_NAME%",
            $host
        );

        $cmd = [
            "docker",
            "compose",
            "-f",
            "/usr/local/lib/doil/server/proxy/docker-compose.yml",
            "up",
            "-d"
        ];

        $logger->info("Start instance doil_proxy");
        $this->run($cmd, $logger);

        // Time for proxy registration on doil master
        sleep(20);

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.proxy state.highstate saltenv=proxyservices"
        ];

        $logger->info("Apply salt highstate on proxy server");
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
            "doil_proxy",
            "doil_proxy:stable"
        ];

        $logger->info("Commit instance doil_proxy");
        $this->run($cmd, $logger);
    }
}