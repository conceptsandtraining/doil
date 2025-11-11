<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Pack;

use RuntimeException;
use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ILIAS\IliasInfo;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class ImportCommandTest extends TestCase
{
    public function test_execute_without_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Not enough arguments (missing: \"instance\").");
        $tester->execute(["package" => "foo"]);
    }

    public function test_execute_without_package_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Not enough arguments (missing: \"package\").");
        $tester->execute(["instance" => "foo"]);
    }

    public function test_execute_with_empty_package_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $filesystem
            ->expects($this->once())
            ->method('parseIniFile')
            ->with("/etc/doil/doil.conf")
            ->willReturn(["host" => "doil", "https_proxy" => false])
        ;

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("The package  does not exists!");
        $tester->execute(["instance" => "foo", "package" => ""]);
    }

    public function test_execute_with_non_existing_package() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $filesystem
            ->expects($this->once())
            ->method('parseIniFile')
            ->with("/etc/doil/doil.conf")
            ->willReturn(["host" => "doil", "https_proxy" => false])
        ;

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("foo")
            ->willReturn(false)
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("The package foo does not exists!");
        $tester->execute(["instance" => "foo", "package" => "foo"]);
    }

    public function test_execute_with_empty_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $filesystem
            ->expects($this->once())
            ->method('parseIniFile')
            ->with("/etc/doil/doil.conf")
            ->willReturn(["host" => "doil", "https_proxy" => false])
        ;

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Name of the instance cannot be empty!");
        $tester->execute(["instance" => "", "package" => "foo.zip"]);
    }

    public function test_execute_with_wrong_chars_in_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $filesystem
            ->expects($this->once())
            ->method('parseIniFile')
            ->with("/etc/doil/doil.conf")
            ->willReturn(["host" => "doil", "https_proxy" => false])
        ;

        $command = new ImportCommand($docker, $posix, $filesystem, $repo_manager, $writer, $ilias_info);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid characters! Only lowercase letters, numbers and underscores are allowed!");
        $tester->execute(["instance" => "FooBar", "package" => "foo.zip"]);
    }
}