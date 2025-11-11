<?php declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\ConsoleOutput;

use Symfony\Component\Console\Output\OutputInterface;

class SetupWriter implements Writer
{
    protected array $blocks = [];
    protected array $section = [];

    public function beginBlock(OutputInterface $output, string $txt) : void
    {
        $section = $output->section();
        $section->writeln($txt . " ...");
        $this->blocks[] = $txt;
        $this->section[] = $section;
    }

    public function endBlock() : void
    {
        $txt = array_pop($this->blocks);
        $section = array_pop($this->section);
        $section->overwrite($txt . " ... <fg=green>done</>");
    }

    public function error(OutputInterface $output, string $msg, string $hint = "") : void
    {
        $output->writeln("<fg=red>Error:</>");
        $output->writeln("\t" . $msg);
        $output->writeln("\t" . $hint);
    }
}