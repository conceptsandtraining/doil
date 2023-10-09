<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use RuntimeException;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class AddCommandTest extends TestCase
{
    public function test_execute_without_name() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($user_manager, $posix, $linux, $filesystem, $writer, $repo_manager);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $tester->execute([]);
    }

    public function test_execute_as_non_root() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($user_manager, $posix, $linux, $filesystem, $writer, $repo_manager);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["name" => "foo1"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_without_home_dir() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($user_manager, $posix, $linux, $filesystem, $writer, $repo_manager);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("foo1")
            ->willReturn(null)
        ;

        $execute_result = $tester->execute(["name" => "foo1"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tUser foo1 has no home directory.\n\tPlease ensure that the user foo1 has a home directory.\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_already_existing_user() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $user = new User("doil");

        $command = new AddCommand($user_manager, $posix, $linux, $filesystem, $writer, $repo_manager);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("doil")
            ->willReturn("/home/doil_test")
        ;

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil_test")
            ->willReturn(true)
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

        $execute_result = $tester->execute(["name" => "doil"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tUser doil already exist!\n\tUse doil user:list to see all user!\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $posix = $this->createMock(Posix::class);
        $linux = $this->createMock(Linux::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);
        $user = new User("doil");

        $command = new AddCommand($user_manager, $posix, $linux, $filesystem, $writer, $repo_manager);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method("isSudo")
            ->willReturn(true)
        ;
        $posix
            ->expects($this->once())
            ->method("getHomeDirectoryByUserName")
            ->with("doil")
            ->willReturn("/home/doil_test")
        ;

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil_test")
            ->willReturn(true)
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
        $user_manager
            ->expects($this->once())
            ->method("addUser")
            ->with($user)
        ;
        $user_manager
            ->expects($this->once())
            ->method("createFileInfrastructure")
            ->with("/home/doil_test", "doil")
        ;

        $linux
            ->expects($this->once())
            ->method("addUserToGroup")
            ->with("doil", "doil")
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $this->assertEquals(0, $execute_result);
    }
}