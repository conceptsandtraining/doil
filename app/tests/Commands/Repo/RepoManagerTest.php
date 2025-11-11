<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class RepoManagerWrapper extends RepoManager
{
    public function getLocalRepos() : array
    {
        return [
            new Repo("local1", "https://local1.git", false),
            new Repo("local2", "https://local2.git", false)
        ];
    }

    public function getGlobalRepos() : array
    {
        return [
            new Repo("global1", "https://global1.git", true),
            new Repo("global2", "https://global2.git", true)
        ];
    }
}

#[AllowMockObjectsWithoutExpectations]
class RepoManagerTest extends TestCase
{
    public function test_create() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManager($git, $posix, $filesystem);

        $this->assertIsObject($repo_manager, RepoManager::class);
    }

    public function test_getEmptyRepo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManager($git, $posix, $filesystem);

        $repo = $repo_manager->getEmptyRepo();

        $this->assertEmpty($repo->getName());
        $this->assertEmpty($repo->getUrl());
        $this->assertFalse($repo->isGlobal());
    }

    public function test_repoNameExists_with_no_repos() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo();

        $repo_manager = new RepoManager($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn(false)
        ;

        $result = $repo_manager->repoNameExists($repo);

        $this->assertFalse($result);
    }

    public function test_repoNameExists_with_existing_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("doil", "http://test/doil.git", false);

        $repo_manager = new RepoManager($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readFromJsonFile")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn([$repo])
        ;

        $result = $repo_manager->repoNameExists($repo);

        $this->assertTrue($result);
    }

    public function test_repoUrlExists_with_no_repos() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo();

        $repo_manager = new RepoManager($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn(false)
        ;

        $result = $repo_manager->repoUrlExists($repo);

        $this->assertFalse($result);
    }

    public function test_repoUrlExists_with_existing_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("doil", "http://test/doil.git", false);

        $repo_manager = new RepoManager($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("readFromJsonFile")
            ->with("/home/doil/.doil/config/repositories.json")
            ->willReturn([$repo])
        ;

        $result = $repo_manager->repoUrlExists($repo);

        $this->assertTrue($result);
    }

    public function test_addRepo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("doil", "http://test/doil.git", false);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

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

        $repos = $repo_manager->getLocalRepos();
        $repos[] = $repo;

        $filesystem
            ->expects($this->once())
            ->method("saveToJsonFile")
            ->with("/home/doil/.doil/config/repositories.json", $repos)
        ;

        $repo_manager->addRepo($repo);
    }

    public function test_deleteRepo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("global1", "http://global1/doil.git", true);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $repos = $repo_manager->getGlobalRepos();
        unset($repos[0]);

        $filesystem
            ->expects($this->once())
            ->method("remove")
            ->with("/usr/local/share/doil/repositories/global1")
        ;
        $filesystem
            ->expects($this->once())
            ->method("saveToJsonFile")
            ->with("/etc/doil/repositories.json", $repos)
        ;

        $repo_manager->deleteRepo($repo);
    }

    public function test_updateRepo_with_already_existing_global_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("global1", "", true);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/repositories/global1")
            ->willReturn(true)
        ;

        $git
            ->expects($this->once())
            ->method("fetchBare")
            ->with("/usr/local/share/doil/repositories/global1")
        ;

        $repo_manager->updateRepo($repo);
    }

    public function test_updateRepo_with_already_existing_local_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("local1", "", false);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/repositories/local1")
            ->willReturn(true)
        ;

        $git
            ->expects($this->once())
            ->method("fetchBare")
            ->with("/home/doil/.doil/repositories/local1")
        ;

        $repo_manager->updateRepo($repo);
    }

    public function test_updateRepo_with_non_existing_global_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("global1", "https://global1.git", true);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/usr/local/share/doil/repositories/global1")
            ->willReturn(false)
        ;

        $git
            ->expects($this->once())
            ->method("cloneBare")
            ->with("https://global1.git", "/usr/local/share/doil/repositories/global1")
        ;

        $repo_manager->updateRepo($repo);
    }

    public function test_updateRepo_with_non_existing_local_repo() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo = new Repo("local1", "https://local1.git", false);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/repositories/local1")
            ->willReturn(false)
        ;

        $git
            ->expects($this->once())
            ->method("cloneBare")
            ->with("https://local1.git", "/home/doil/.doil/repositories/local1")
        ;

        $repo_manager->updateRepo($repo);
    }

    public function test_getLocalRepoByName_fail() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Repo with name 'undefined' not found in local repos.");

        $repo_manager->getLocalRepoByName("undefined");
    }

    public function test_getLocalRepoByUrl_fail() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Repo with url 'undefined' not found in local repos.");

        $repo_manager->getLocalRepoByUrl("undefined");
    }

    public function test_getGlobalRepoByName_fail() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Repo with name 'undefined' not found in global repos.");

        $repo_manager->getGlobalRepoByName("undefined");
    }

    public function test_getLocalRepoByName() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $result = $repo_manager->getLocalRepoByName("local1");

        $this->assertIsObject($result, Repo::class);
        $this->assertEquals("local1", $result->getName());
        $this->assertEquals("https://local1.git", $result->getUrl());
        $this->assertFalse($result->isGlobal());
    }

    public function test_getLocalRepoByUrl() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $result = $repo_manager->getLocalRepoByUrl("https://local1.git");

        $this->assertIsObject($result, Repo::class);
        $this->assertEquals("local1", $result->getName());
        $this->assertEquals("https://local1.git", $result->getUrl());
        $this->assertFalse($result->isGlobal());
    }

    public function test_getGlobalRepoByName() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $result = $repo_manager->getGlobalRepoByName("global1");

        $this->assertIsObject($result, Repo::class);
        $this->assertEquals("global1", $result->getName());
        $this->assertEquals("https://global1.git", $result->getUrl());
        $this->assertTrue($result->isGlobal());
    }

    public function test_getGlobalRepoByUrl_fail() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Repo with url 'undefined' not found in global repos.");

        $repo_manager->getGlobalRepoByUrl("undefined");
    }

    public function test_getGlobalRepoByUrl() : void
    {
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);

        $repo_manager = new RepoManagerWrapper($git, $posix, $filesystem);

        $result = $repo_manager->getGlobalRepoByUrl("https://global1.git");

        $this->assertIsObject($result, Repo::class);
        $this->assertEquals("global1", $result->getName());
        $this->assertEquals("https://global1.git", $result->getUrl());
        $this->assertTrue($result->isGlobal());
    }
}