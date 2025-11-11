<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'salt:states',
    description: "List all currently available states to apply."
)]
class StatesCommand extends Command
{
    protected const PATH_STATES = "/usr/local/share/doil/stack/states";

    public function __construct(protected Filesystem $filesystem)
    {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $states = $this->filesystem->getFilesInPath(self::PATH_STATES);

        foreach ($states as $state) {
            $output->writeln($state);
        }

        return Command::SUCCESS;
    }
}