<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\ConsoleOutput;

use Symfony\Component\Console\Output\OutputInterface;

interface Writer
{
    public function beginBlock(OutputInterface $output, string $txt) : void;
    public function endBlock() : void;
    public function error(OutputInterface $output, string $msg, string $hint = "") : void;
}