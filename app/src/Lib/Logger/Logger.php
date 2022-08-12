<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Logger;

interface Logger
{
    public function info(string $text) : void;
    public function warning(string $text) : void;
    public function critical(string $text) : void;
    public function alert(string $text) : void;
    public function error(string $text) : void;
    public function notice(string $text) : void;
}