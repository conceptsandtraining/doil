<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Salt;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;

class UpCommandTest extends TestCase
{
    public function test_execute_salt_already_up() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new UpCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/salt")
            ->willReturn(true);

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Nothing to do. Salt is already up.\n";

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
            ->with("/usr/local/lib/doil/server/salt")
            ->willReturn(false);
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/salt")
        ;
        $docker
            ->expects($this->once())
            ->method("getRunningInstanceNames")
            ->willReturn(["foo1", "foo2"])
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("executeDockerCommand")
            ->withConsecutive(
                ["foo1", "supervisorctl start startup"],
                ["foo2", "supervisorctl start startup"],
                ["doil_proxy", "supervisorctl start startup"],
            )
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}