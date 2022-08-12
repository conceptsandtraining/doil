<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Posix;

class PosixShell implements Posix
{
    public function getUserId() : int
    {
        return posix_getuid();
    }

    public function getGroupId() : int
    {
        return posix_getgid();
    }

    public function getCurrentUserName() : string
    {
        return posix_getpwuid(posix_geteuid())['name'];
    }

    public function getHomeDirectory(int $user_id) : string
    {
        return posix_getpwuid($user_id)['dir'];
    }

    public function getHomeDirectoryByUserName(string $name) : ?string
    {
        $result = posix_getpwnam($name);

        if ($result === false) {
            return null;
        }

        return $result["dir"];
    }
}