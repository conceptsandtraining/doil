<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Console\Output\OutputInterface;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class LoginCommandWrapper extends LoginCommand
{
    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        return true;
    }
}

#[AllowMockObjectsWithoutExpectations]
class LoginCommandTest extends TestCase
{
    public function test_execute_with_no_instance_name() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $command = new LoginCommandWrapper($docker, $posix, $filesystem);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("getCurrentWorkingDirectory")
            ->willReturn("/tmp/doil_test")
        ;
        $filesystem
            ->expects($this->once())
            ->method("getFilenameFromPath")
            ->with("/tmp/doil_test")
            ->willReturn("doil_test")
        ;

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/tmp/doil_test")
            ->willReturn(false)
        ;
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/tmp/doil_test")
        ;
        $docker
            ->expects($this->once())
            ->method("loginIntoContainer")
            ->with("/tmp/doil_test", "doil_test")
        ;

        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_with_no_instance_name_and_no_docker_compose_file() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $command = new LoginCommand($docker, $posix, $filesystem);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("getCurrentWorkingDirectory")
            ->willReturn("/tmp/doil_test")
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n";
        $result .= "\tCan't find a suitable docker-compose file in this directory '/tmp/doil_test'.\n";
        $result .= "\tIs this the right directory?\n\tSupported filenames: docker-compose.yml\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_instance_name() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $instance = "master";

        $command = new LoginCommandWrapper($docker, $posix, $filesystem);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(22)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(22)
            ->willReturn("/tmp/doil_test")
        ;

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/tmp/doil_test/.doil/instances/master")
            ->willReturn(false)
        ;
        $docker
            ->expects($this->once())
            ->method("startContainerByDockerCompose")
            ->with("/tmp/doil_test/.doil/instances/master")
        ;
        $docker
            ->expects($this->once())
            ->method("loginIntoContainer")
            ->with("/tmp/doil_test/.doil/instances/master", "master")
        ;

        $execute_result = $tester->execute(["instance" => $instance]);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_with_instance_name_and_no_docker_compose_file() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $instance = "master";

        $command = new LoginCommand($docker, $posix, $filesystem);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(22)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(22)
            ->willReturn("/tmp/doil_test")
        ;

        $execute_result = $tester->execute(["instance" => $instance]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n";
        $result .= "\tCan't find a suitable docker-compose file in this directory '/tmp/doil_test/.doil/instances/master'.\n";
        $result .= "\tIs this the right directory?\n\tSupported filenames: docker-compose.yml\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }
}