<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\ILIAS;

interface ILIAS
{
    public function getIliasVersion(string $path) : string;
}