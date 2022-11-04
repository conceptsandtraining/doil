<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib;

use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

trait SymfonyShell
{
    protected function run(array $commands) : string
    {
        $process = new Process($commands);
        $process->setTimeout(36000);
        $process->run();

        // executes after the command finishes
        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        return $process->getOutput();
    }

    protected function runTTY(array $commands) : void
    {
        $process = new Process($commands);
        $process->setTty(true);
        $process->setTimeout(36000);
        $process->run();
    }

    protected function runTTYQuiet(array $commands) : void
    {
        $process = new Process($commands);
        $process->setTty(true);
        $process->setTimeout(36000);
        $process->disableOutput();
        $process->run();
    }
}