<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Salt;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class StatesCommand extends Command
{
    protected const PATH_STATES = "/usr/local/share/doil/stack/states";

    protected static $defaultName = "salt:states";
    protected static $defaultDescription = "List all currently available states to apply";

    protected Filesystem $filesystem;

    public function __construct(Filesystem $filesystem)
    {
        parent::__construct();

        $this->filesystem = $filesystem;
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