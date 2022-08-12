<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Proxy;

use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ReloadCommand extends Command
{
    use CLIHelper;

    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";

    protected static $defaultName = "proxy:reload";
    protected static $defaultDescription = "Reloads the proxy server configuration";

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

        $this->writer->beginBlock($output, "Reload proxy server");
        $this->docker->executeQuietCommand(self::PROXY_PATH, "doil_proxy", "/etc/init.d/nginx", "reload");
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}