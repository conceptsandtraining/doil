<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;

class UserManagerTest extends TestCase
{
    public function test_create() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);

        $this->assertIsObject($user_manager, UserManager::class);
    }

    public function test_createUser() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);

        $user = $user_manager->createUser("doil");

        $this->assertIsObject($user, User::class);
        $this->assertEquals("doil", $user->getName());
    }

    public function test_userExists_false() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/etc/doil/user.json")
            ->willReturn(false)
        ;

        $user = $user_manager->createUser("foo");
        $result = $user_manager->userExists($user);

        $this->assertFalse($result);
    }

    public function test_userExists_true() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);
        $user = $user_manager->createUser("foo");

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/etc/doil/user.json")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readFromJsonFile")
            ->with("/etc/doil/user.json")
            ->willReturn([$user])
        ;

        $result = $user_manager->userExists($user);

        $this->assertTrue($result);
    }

    public function test_addUser() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);
        $user = $user_manager->createUser("foo");

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/etc/doil/user.json")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readFromJsonFile")
            ->with("/etc/doil/user.json")
            ->willReturn([])
        ;
        $filesystem
            ->expects($this->once())
            ->method("saveToJsonFile")
            ->with("/etc/doil/user.json", [$user])
        ;

        $user_manager->addUser($user);
    }

    public function test_createFileInfrastructure() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);

        $filesystem
            ->expects($this->exactly(3))
            ->method("makeDirectoryRecursive")
            ->withConsecutive(
                ["/tmp/doil_test/.doil/config"],
                ["/tmp/doil_test/.doil/repositories"],
                ["/tmp/doil_test/.doil/instances"]
            )
        ;
        $filesystem
            ->expects($this->once())
            ->method("chownRecursive")
            ->with("/tmp/doil_test/.doil", "doil", "doil")
        ;

        $user_manager->createFileInfrastructure("/tmp/doil_test", "doil");
    }

    public function test_deleteFileInfrastructure() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);

        $filesystem
            ->expects($this->once())
            ->method("remove")
            ->with("/tmp/doil_test/.doil")
        ;

        $user_manager->deleteFileInfrastructure("/tmp/doil_test");
    }

    public function test_deleteUser() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $user_manager = new UserManager($filesystem);
        $user = $user_manager->createUser("foo");

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/etc/doil/user.json")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readFromJsonFile")
            ->with("/etc/doil/user.json")
            ->willReturn([$user])
        ;
        $filesystem
            ->expects($this->once())
            ->method("saveToJsonFile")
            ->with("/etc/doil/user.json", [])
        ;

        $user_manager->deleteUser($user);
    }
}