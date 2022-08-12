<?php declare(strict_types=1);

namespace CaT\Doil\Commands\System;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Commands\User\User;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\User\UserManager;
use Symfony\Component\Console\Application;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class UninstallCommandTest extends TestCase
{
    public function test_execute_as_non_sudo() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $user_manager = $this->createMock(UserManager::class);
        $writer = new CommandWriter();

        $command = new UninstallCommand($docker, $posix, $filesystem, $linux, $user_manager, $writer);
        $tester = new CommandTester($command);

       $posix
           ->expects($this->once())
           ->method("getUserId")
           ->willReturn(1)
       ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_abort_by_user() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $user_manager = $this->createMock(UserManager::class);
        $writer = new CommandWriter();

        $command = new UninstallCommand($docker, $posix, $filesystem, $linux, $user_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(0)
        ;

        $tester->setInputs(["N"]);
        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Please confirm that you want to uninstall doil [yN]: Abort by user!\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $user_manager = $this->createMock(UserManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new UninstallCommand($docker, $posix, $filesystem, $linux, $user_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $user1 = new User("user1");
        $user2 = new User("user2");

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(0)
        ;

        $user_manager
            ->expects($this->once())
            ->method("getUsers")
            ->willReturn([$user1, $user2])
        ;

        $filesystem
            ->expects($this->exactly(3))
            ->method("exists")
            ->withConsecutive(
                ["/home/user1/.doil/instances"],
                ["/home/user2/.doil/instances"],
                ["/usr/local/share/doil/instances"]
            )
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->exactly(3))
            ->method("getFilesInPath")
            ->withConsecutive(
                ["/home/user1/.doil/instances"],
                ["/home/user2/.doil/instances"],
                ["/usr/local/share/doil/instances"]
            )
            ->willReturnOnConsecutiveCalls(
                ["local1", "local2"],
                ["local3", "local4"],
                ["global1", "global2"]
            )
        ;
        $filesystem
            ->expects($this->exactly(4))
            ->method("readLink")
            ->withConsecutive(
                ["/home/user1/.doil/instances/local1"],
                ["/home/user1/.doil/instances/local2"],
                ["/home/user2/.doil/instances/local3"],
                ["/home/user2/.doil/instances/local4"]
            )
            ->willReturnOnConsecutiveCalls(
                "/home/user1/doil/instances/local1",
                "/home/user1/doil/instances/local2",
                "/home/user2/doil/instances/local3",
                "/home/user2/doil/instances/local4",
            )
        ;
        $filesystem
            ->expects($this->exactly(14))
            ->method("remove")
            ->withConsecutive(
                ["/home/user1/.doil/instances/local1"],
                ["/home/user1/doil/instances/local1"],
                ["/home/user1/.doil/instances/local2"],
                ["/home/user1/doil/instances/local2"],
                ["/home/user2/.doil/instances/local3"],
                ["/home/user2/doil/instances/local3"],
                ["/home/user2/.doil/instances/local4"],
                ["/home/user2/doil/instances/local4"],
                ["/etc/doil"],
                ["/usr/local/lib/doil"],
                ["/usr/local/share/doil"],
                ["/usr/local/bin/doil"],
                ["/home/user1/.doil"],
                ["/home/user2/.doil"],
            )
        ;

        $docker
            ->expects($this->exactly(3))
            ->method("deleteInstances")
            ->withConsecutive(
                [["local1_local", "local2_local"]],
                [["local3_local", "local4_local"]],
                [["global1_global", "global2_global"]]
            )
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("stopContainerByDockerCompose")
            ->withConsecutive(
                ["/usr/local/lib/doil/server/proxy"],
                ["/usr/local/lib/doil/server/salt"],
                ["/usr/local/lib/doil/server/mail"]
            )
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("removeContainer")
            ->withConsecutive(
                ["doil_proxy"],
                ["doil_saltmain"],
                ["doil_postfix"]
            )
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("getImageIdsByName")
            ->withConsecutive(
                ["doil_proxy"],
                ["doil_saltmain"],
                ["doil_postfix"]
            )
            ->willReturnOnConsecutiveCalls(
                ["123"],
                ["456"],
                ["789"]
            )
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("removeImage")
            ->withConsecutive(
                ["123"],
                ["456"],
                ["789"]
            )
        ;
        $docker
            ->expects($this->exactly(3))
            ->method("removeVolume")
            ->withConsecutive(
                ["proxy"],
                ["salt"],
                ["mail"]
            )
        ;
        $docker
            ->expects($this->once())
            ->method("pruneNetworks")
        ;

        $linux
            ->expects($this->once())
            ->method("deleteGroup")
            ->with("doil")
        ;

        $tester->setInputs(["y"]);
        $execute_result = $tester->execute([]);
        $this->assertEquals(0, $execute_result);
    }
}