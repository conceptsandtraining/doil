<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Git;

interface Git
{
    public function getBranches(string $path) : array;
    public function fetchBare(string $path, string $url) : void;
    public function cloneBare(string $url, string $path) : void;
    public function setLocalConfig(string $path, ...$commands) : void;
    public function checkoutRemote(string $path, string $branch) : void;
}