<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Git;

use CaT\Doil\Lib\SymfonyShell;

class GitShell implements Git
{
    use SymfonyShell;

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

        return array_filter(explode("\n", $this->run($cmd)));
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

        $this->runTTYQuiet($cmd);
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

        $this->runTTYQuiet($cmd);
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

        $this->runTTY($cmd);
    }

//    public function setFileMode(string $path, string $file_mode) : void
//    {
//        $cmd = [
//            "git",
//            "-C",
//            $path,
//            "config",
//            "core.fileMode",
//            $file_mode
//        ];
//
//        $this->runTTYQuiet($cmd);
//    }

    public function checkoutRemote(string $path, string $branch) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "checkout",
            $branch
        ];

        $this->runTTYQuiet($cmd);
    }

    public function deleteBranch(string $path, string $branch) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "branch",
            "-D",
            "$branch"
        ];

        $this->runTTYQuiet($cmd);
    }

    public function checkoutNew(string $path, string $branch) : void
    {
        $cmd = [
            "git",
            "-C",
            $path,
            "checkout",
            "-b",
            "$branch"
        ];

        $this->runTTYQuiet($cmd);
    }
}