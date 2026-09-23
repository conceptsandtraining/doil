<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Salt;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
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
            ->with("/usr/local/lib/doil/server/salt")
            ->willReturn(false);
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/salt")
        ;
        $docker
            ->expects($this->once())
            ->method("executeCommand")
            ->with("/usr/local/lib/doil/server/salt", "doil_salt", "salt-key", "-y", "-D")
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}