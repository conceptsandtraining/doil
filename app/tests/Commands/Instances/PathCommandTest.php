<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class PathCommandTest extends TestCase
{
    public function test_execute_with_missing_instance() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();

        $command = new PathCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $execute_result = $tester->execute(["instance" => ""]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_local_path() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);

        $command = new PathCommand($docker, $posix, $filesystem, $writer);
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
            ->willReturn("/home/doil")
        ;

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/instances/master")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readLink")
            ->with("/home/doil/.doil/instances/master")
            ->willReturn("/home/user/instances/master")
        ;

        $execute_result = $tester->execute(["instance" => "master", "--global" => false]);
        $output = $tester->getDisplay(true);

        $result = "/home/user/instances/master\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_with_global_path() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);

        $command = new PathCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readLink")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn("/home/user/instances/master")
        ;

        $execute_result = $tester->execute(["instance" => "master", "--global" => true]);
        $output = $tester->getDisplay(true);

        $result = "/home/user/instances/master\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_with_non_existing_path() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();

        $command = new PathCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["instance" => "master", "--global" => true]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }
}