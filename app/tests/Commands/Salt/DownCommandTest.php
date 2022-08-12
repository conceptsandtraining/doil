<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Salt;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;

class DownCommandTest extends TestCase
{
    public function test_execute_salt_already_down() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new DownCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/salt")
            ->willReturn(false);

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Nothing to do. Salt is already down.\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new DownCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/salt")
            ->willReturn(true);
        $docker
            ->expects($this->once())
            ->method("stopContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/salt")
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}