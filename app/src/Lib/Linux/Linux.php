<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Linux;

interface Linux
{
    public function addUserToGroup(string $user, string $group) : void;
    public function removeUserFromGroup(string $user, string $group) : void;
    public function deleteGroup(string $name) : void;
    public function isWSL() : bool;
}