<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Proxy;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class LoginCommandTest extends TestCase
{
    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);

        $command = new LoginCommand($docker);
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
            ->method("loginIntoContainer")
            ->with("/usr/local/lib/doil/server/proxy")
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}