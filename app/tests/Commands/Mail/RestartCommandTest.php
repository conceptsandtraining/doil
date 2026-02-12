<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Mail;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class RestartCommandTest extends TestCase
{
    public function test_execute_mail_already_down() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);

        $command = new RestartCommand($docker, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/lib/doil/server/mail")
            ->willReturn(false);
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/mail")
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
            ->with("/usr/local/lib/doil/server/mail")
            ->willReturn(true);
        $docker
            ->expects($this->once())
            ->method("stopContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/mail")
        ;
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/usr/local/lib/doil/server/mail")
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}