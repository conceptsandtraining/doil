<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Proxy;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'proxy:down',
    description: "Stops the proxy server."
)]
class DownCommand extends Command
{
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";

    public function __construct(
        protected Docker $docker,
        protected Writer $writer
    ) {
        parent::__construct();
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::PROXY_PATH)) {
            $output->writeln("Nothing to do. Proxy is already down.");
            return Command::SUCCESS;
        }

        $this->writer->beginBlock($output, "Stop proxy server");
        $this->docker->stopContainerByDockerCompose(self::PROXY_PATH);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}