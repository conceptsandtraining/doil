<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class DeleteCommandTest extends TestCase
{
    public function test_execute_without_name_and_all() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($user_manager, $posix, $linux, $writer);
        $tester = new CommandTester($command);

        $this->expectException(InvalidArgumentException::class);
        $tester->execute([]);
    }

    public function test_execute_as_non_root() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($user_manager, $posix, $linux, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(1)
        ;

        $execute_result = $tester->execute(["name" => "foo1"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_already_existing_user() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($user_manager, $posix, $linux, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(0)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("doil")
            ->willReturn(null)
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tUser doil is not a system user!\n\tPlease ensure that the user doil is a system user.\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_non_existing_user() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $writer = new CommandWriter();
        $user = new User("doil");

        $command = new DeleteCommand($user_manager, $posix, $linux, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(0)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("doil")
            ->willReturn("/home/doil_test")
        ;

        $user_manager
            ->expects($this->once())
            ->method("createUser")
            ->with("doil")
            ->willReturn($user)
        ;
        $user_manager
            ->expects($this->once())
            ->method("userExists")
            ->with($user)
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tUser doil does not exist!\n\tUse doil user:list to see all user!\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $writer = $this->createMock(Writer::class);
        $user = new User("doil");

        $command = new DeleteCommand($user_manager, $posix, $linux, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("getUserId")
            ->willReturn(0)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("doil")
            ->willReturn("/home/doil_test")
        ;

        $user_manager
            ->expects($this->once())
            ->method("createUser")
            ->with("doil")
            ->willReturn($user)
        ;
        $user_manager
            ->expects($this->once())
            ->method("userExists")
            ->with($user)
            ->willReturn(true)
        ;
        $user_manager
            ->expects($this->once())
            ->method("deleteUser")
            ->with($user)
        ;
        $user_manager
            ->expects($this->once())
            ->method("deleteFileInfrastructure")
            ->with("/home/doil_test")
        ;

        $linux
            ->expects($this->once())
            ->method("removeUserFromGroup")
            ->with("doil", "doil")
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $this->assertEquals(0, $execute_result);
    }
}