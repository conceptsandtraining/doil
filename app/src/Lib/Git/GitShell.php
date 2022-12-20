<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Git;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use CaT\Doil\Lib\Logger\LoggerFactory;

class GitShell implements Git
{
    use SymfonyShell;

    protected LoggerInterface $logger;

    public function __construct(LoggerFactory $logger)
    {
        $this->logger = $logger->getDoilLogger("GIT");
    }

    public function getBranches(string $path) : array
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "branch",
            "-a",
            "--format=%(refname:short)",
        ];

        $this->logger->info("Retrieve branches from path '$path'");
        return array_filter(explode("\n", $this->run($cmd, $this->logger)));
    }

    public function fetchBare(string $path, string $url) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "fetch",
            $url
        ];

        $this->logger->info("Fetch url '$url' to path '$path'");
        $this->run($cmd, $this->logger);
    }

    public function cloneBare(string $url, string $path) : void
    {
        $cmd = [
            "git",
            "clone",
            "--bare",
            $url,
            $path
        ];

        $this->logger->info("Clone bare from url '$url' to path '$path'");
        $this->run($cmd, $this->logger);
    }

    public function setLocalConfig(string $path, ...$commands) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "config",
            "--local"
        ];

        $cmd = array_merge($cmd, $commands);

        $this->logger->info("Set local config for path '$path'", $commands);
        $this->runTTY($cmd, $this->logger);
    }

    public function checkoutRemote(string $path, string $branch) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "checkout",
            $branch
        ];

        $this->logger->info("Check out remote branch '$branch' for path '$path'");
        $this->run($cmd, $this->logger);
    }
}