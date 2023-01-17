<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Posix;

interface Posix
{
    public function getUserId() : int;
    public function isSudo() : bool;
    public function getGroupId() : int;
    public function getCurrentUserName() : string;
    public function getHomeDirectory(int $user_id) : string;
    public function getHomeDirectoryByUserName(string $name) : ?string;
}