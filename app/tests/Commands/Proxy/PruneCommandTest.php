<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Proxy;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;

class PruneCommandTest extends TestCase
{
    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new PruneCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/proxy")
            ->willReturn(false);
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/proxy")
        ;
        $docker
            ->expects($this->once())
            ->method("listContainerDirectory")
            ->with("doil_proxy", "/etc/nginx/conf.d/sites/")
            ->willReturn(["foo1", "foo2"])
        ;
        $docker
            ->expects($this->exactly(2))
            ->method("executeCommand")
            ->withConsecutive(
                [
                    "/usr/local/lib/doil/server/proxy",
                    "doil_proxy",
                    "rm",
                    "/etc/nginx/conf.d/sites/foo1"
                ],
                [
                    "/usr/local/lib/doil/server/proxy",
                    "doil_proxy",
                    "rm",
                    "/etc/nginx/conf.d/sites/foo2"
                ],
            )
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}