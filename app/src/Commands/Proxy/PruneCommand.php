<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Proxy;

use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class PruneCommand extends Command
{
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";

    protected static $defaultName = "proxy:prune";
    protected static $defaultDescription = "Prunes the proxy server";

    protected Docker $docker;
    protected Writer $writer;

    public function __construct(Docker $docker, Writer $writer)
    {
        parent::__construct();

        $this->docker = $docker;
        $this->writer = $writer;
    }


    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->docker->isInstanceUp(self::PROXY_PATH)) {
            $this->docker->startContainerByDockerCompose(self::PROXY_PATH);
        }

        $this->writer->beginBlock($output, "Prune proxy server");
        $files = $this->docker->listContainerDirectory("doil_proxy", "/etc/nginx/conf.d/sites/");
        foreach ($files as $file) {
            $this->docker->executeCommand(self::PROXY_PATH, "doil_proxy", "rm", "/etc/nginx/conf.d/sites/$file");
        }
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}