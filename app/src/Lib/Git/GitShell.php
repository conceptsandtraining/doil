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
            "--format=%(refname:short)",
        ];

        $this->logger->info("Retrieve branches from path '$path'");
        return array_filter(explode("\n", $this->run($cmd, $this->logger)));
    }

    public function getCurrentBranch(string $path) : string
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "rev-parse",
            "--abbrev-ref",
            "HEAD"
        ];
        return trim($this->run($cmd, $this->logger));
    }

    public function fetchBare(string $path) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "fetch",
            "-p"
        ];

        $this->logger->info("Fetch to path '$path'");
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

    public function getRemotes(string $path) : array
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "remote",
            "-v"
        ];

        $this->logger->info("Get remote repos for $path");
        $result = $this->run($cmd, $this->logger);
        $result = explode("\n", $result);
        array_pop($result);

        foreach ($result as $r) {
            $r = preg_split('/\s+/', $r);
            $arr[$r[0]] = $r[1];
        }

        return $arr;
    }

    public function isBranchInRepo(string $path, string $url, string $branch) : bool
    {
        $cmd = [
            "git",
            "ls-remote",
            "--heads",
            $url,
            "refs/heads/$branch"
        ];

        $this->logger->info("Get remote repos for $path");
        $result = $this->run($cmd, $this->logger);

        if ($result == "") {
            return false;
        }
        return true;
    }
}