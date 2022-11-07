<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil;

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Command\Command;

class App extends Application
{
    const NAME = "Doil Version 20221107 - build 2022-11-07";

    public function __construct(Command ...$commands)
    {
        parent::__construct(self::NAME);

        foreach ($commands as $command) {
            $this->add($command);
        }
    }
}