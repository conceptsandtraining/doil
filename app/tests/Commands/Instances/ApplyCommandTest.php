<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class ApplyCommandTest extends TestCase
{
    public function test_execute_with_non_existing_global_dir() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new ApplyCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/instances/$instance")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["instance" => "master", "--global" => true]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_non_existing_local_dir() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new ApplyCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/instances/$instance")
            ->willReturn(false)
        ;

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(1000)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(1000)
            ->willReturn("/home/doil")
        ;

        $execute_result = $tester->execute(["instance" => "master"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_state_not_in_path() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new ApplyCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->exactly(2))
            ->method("exists")
            ->withConsecutive(["/home/doil/.doil/instances/$instance"], ["/usr/local/share/doil/stack/states/access"])
            ->willReturnOnConsecutiveCalls(true, false)
        ;

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(1000)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(1000)
            ->willReturn("/home/doil")
        ;

        $tester->setInputs(["access"]);
        $execute_result = $tester->execute(["instance" => "master", "state" => "access"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tThe state access does not exists!\n\tUse doil instances:apply --help for mor information.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_state() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);
        $instance = "master";

        $command = new ApplyCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->exactly(2))
            ->method("exists")
            ->withConsecutive(["/home/doil/.doil/instances/$instance"], ["/usr/local/share/doil/stack/states/access"])
            ->willReturnOnConsecutiveCalls(true, true)
        ;

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(1000)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(1000)
            ->willReturn("/home/doil")
        ;

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/home/doil/.doil/instances/master")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->once())
            ->method("getSaltAcceptedKeys")
            ->willReturn(["master.local"])
        ;
        $docker
            ->expects($this->once())
            ->method("applyState")
            ->with("master.local", "access")
        ;
        $docker
            ->expects($this->once())
            ->method("commit")
            ->with("master_local")
        ;

        $execute_result = $tester->execute(["instance" => "master", "state" => "access"]);

        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_with_state_and_no_commit() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);
        $instance = "master";

        $command = new ApplyCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->exactly(2))
            ->method("exists")
            ->withConsecutive(["/home/doil/.doil/instances/$instance"], ["/usr/local/share/doil/stack/states/access"])
            ->willReturnOnConsecutiveCalls(true, true)
        ;

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(1000)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectory")
            ->with(1000)
            ->willReturn("/home/doil")
        ;

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/home/doil/.doil/instances/master")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->once())
            ->method("getSaltAcceptedKeys")
            ->willReturn(["master.local"])
        ;
        $docker
            ->expects($this->once())
            ->method("applyState")
            ->with("master.local", "access")
        ;

        $execute_result = $tester->execute(["instance" => "master", "state" => "access", "--no_commit" => true]);

        $this->assertEquals(0, $execute_result);
    }
}