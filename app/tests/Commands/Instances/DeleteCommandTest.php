<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Application;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class DeleteCommandTest extends TestCase
{
    public function test_execute_with_non_root_user() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new DeleteCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["instance" => $instance, "--global" => false]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";
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

        $command = new DeleteCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
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
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["instance" => $instance, "--global" => false]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_non_existing_global_dir() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new DeleteCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["instance" => $instance, "--global" => true]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tInstance not found!\n\tUse doil instances:list to see current installed instances.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_user_abort() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();
        $instance = "master";

        $command = new DeleteCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(true)
        ;

        $tester->setInputs(["no"]);
        $execute_result = $tester->execute(["instance" => $instance, "--global" => true]);
        $output = $tester->getDisplay(true);

        $result = "Please confirm that you want to delete master [yN]: Abort by user!\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);
        $instance = "master";

        $command = new DeleteCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $filesystem
            ->expects($this->exactly(1))
            ->method("exists")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(true)
        ;

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(22)
        ;
        $posix
            ->expects($this->once())
            ->method("getGroupId")
            ->willReturn(33)
        ;

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->exactly(6))
            ->method("executeCommand")
            ->withConsecutive(
                ["/usr/local/share/doil/instances/master", "master", "chown", "-R", "22:33", "/var/lib/mysql"],
                ["/usr/local/share/doil/instances/master", "master", "chown", "-R", "22:33", "/etc/mysql"],
                ["/usr/local/share/doil/instances/master", "master", "chown", "-R", "22:33", "/etc/php"],
                ["/usr/local/lib/doil/server/salt/", "doil_saltmain", "salt-key", "-d", "master.global", "-y", "-q"],
                ["/usr/local/lib/doil/server/proxy/", "doil_proxy", "/bin/bash", "-c", "/etc/init.d/nginx reload &>/dev/null"],
                ["/usr/local/lib/doil/server/mail/", "doil_mail", "/bin/bash", "-c", "/root/delete-postbox-configuration.sh $instance &>/dev/null"]
            )
        ;
        $docker
            ->expects($this->once())
            ->method("stopContainerByDockerCompose")
            ->with("/usr/local/share/doil/instances/master")
        ;
        $docker
            ->expects($this->once())
            ->method("removeContainer")
            ->with("master_global")
        ;
        $docker
            ->expects($this->once())
            ->method("hasVolume")
            ->with("master")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->once())
            ->method("removeVolume")
            ->with("master")
        ;
        $docker
            ->expects($this->once())
            ->method("getImageIdsByName")
            ->with("doil/master_global")
            ->willReturn(["12345"])
        ;
        $docker
            ->expects($this->once())
            ->method("removeImage")
            ->with("12345")
        ;

        $filesystem
            ->expects($this->once())
            ->method("readLink")
            ->with("/usr/local/share/doil/instances/master")
            ->willReturn("/home/user/instances/master")
        ;
        $filesystem
            ->expects($this->exactly(2))
            ->method("remove")
            ->withConsecutive(
                ["/usr/local/share/doil/instances/master"],
                ["/home/user/instances/master"]
            )
        ;

        $tester->setInputs(["yes"]);
        $execute_result = $tester->execute(["instance" => $instance, "--global" => true]);

        $this->assertEquals(0, $execute_result);
    }
}