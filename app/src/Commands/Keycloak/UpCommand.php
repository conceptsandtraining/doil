<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Keycloak;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'keycloak:up',
    description: "Starts the keycloak server."
)]
class UpCommand extends Command
{
    protected const KEYCLOAK_PATH = "/usr/local/lib/doil/server/keycloak";

    public function __construct(
        protected Docker $docker,
        protected Writer $writer,
        protected Filesystem $filesystem
    ) {
        parent::__construct();
    }

    protected function configure() : void
    {
        if (!$this->filesystem->exists(self::KEYCLOAK_PATH)) {
            $this->setHidden();
        }
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if ($this->docker->isInstanceUp(self::KEYCLOAK_PATH)) {
            $output->writeln("Nothing to do. Keycloak is already up.");
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Start keycloak");

        $this->docker->startContainerByDockerCompose(self::KEYCLOAK_PATH);

        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}