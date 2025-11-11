<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Salt;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class RestartCommandTest extends TestCase
{
    public function test_execute_salt_already_down() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new RestartCommand($docker, $writer);
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

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new RestartCommand($docker, $writer);
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
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/salt")
        ;

        $docker
            ->expects($this->once())
            ->method("getRunningInstanceNames")
            ->willReturn(["foo1_local", "foo2_global"])
        ;
        $matcher = $this->exactly(2);
        $docker
            ->expects($matcher)
            ->method("executeDockerCommand")
            ->willReturnCallback(function (... $values) use ($matcher) {
                match ($matcher->numberOfInvocations()) {
                    1 => $values == [
                            "foo1_local",
                            "supervisorctl start startup 2>&1 >/dev/null"
                        ],
                    2 => $values == [
                            "foo2_global",
                            "supervisorctl start startup 2>&1 >/dev/null"
                        ],
                };
            })
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}