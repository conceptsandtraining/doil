<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\ConsoleOutput;

use Symfony\Component\Console\Output\NullOutput;

class NullOutputWrapper extends NullOutput
{
    public function section() : object
    {
        return new class {
            public function writeln(string $s) : void
            {
            }

            public function overwrite(string $s) : void
            {
            }
        };
    }
}