<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Mail;

use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class ChangePasswordCommandTest extends TestCase
{
    public function test_execute_as_non_root() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = new CommandWriter();
        $posix = $this->createMock(Posix::class);

        $command = new ChangePasswordCommand($docker, $writer, $posix);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["password" => "foo"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }
    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $writer = $this->createMock(Writer::class);
        $posix = $this->createMock(Posix::class);

        $command = new ChangePasswordCommand($docker, $writer, $posix);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;

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
        $docker
            ->expects($this->once())
            ->method("getShadowHashForInstance")
            ->with("doil.mail", "foo")
            ->willReturn('$xyz')
        ;
        $docker
            ->expects($this->once())
            ->method("setGrain")
            ->with("doil.mail", "roundcube_password", '\$xyz')
        ;
        $docker
            ->expects($this->once())
            ->method("applyState")
            ->with("doil.mail", "change-roundcube-password")
        ;
        $docker
            ->expects($this->once())
            ->method("commit")
            ->with("doil_mail", "doil_mail")
        ;

        $tester->execute(["password" => "foo"]);
    }
}