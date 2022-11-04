<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Linux;

use CaT\Doil\Lib\SymfonyShell;

class LinuxShell implements Linux
{
    use SymfonyShell;

    public function addUserToGroup(string $user, string $group) : void
    {
        $cmd = [
            "usermod",
            "-a",
            "-G",
            $group,
            $user
        ];

        $this->run($cmd);
    }

    public function removeUserFromGroup(string $user, string $group) : void
    {
        $cmd = [
            "deluser",
            $user,
            $group
        ];

        $this->run($cmd);
    }

    public function deleteGroup(string $name) : void
    {
        $cmd = [
            "groupdel",
            $name
        ];

        $this->run($cmd);
    }

    public function isWSL() : bool
    {
        $cmd = [
            "cat",
            "/proc/version"
        ];

        $wsl = $this->run($cmd);
        return (bool) stristr($wsl, "microsoft");
    }
}