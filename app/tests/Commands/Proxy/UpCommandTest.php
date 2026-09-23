<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Proxy;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class UpCommandTest extends TestCase
{
    public function test_execute_proxy_already_up() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new UpCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/proxy")
            ->willReturn(true);

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Nothing to do. Proxy is already up.\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new UpCommand($docker, $writer);
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

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}