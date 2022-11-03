<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use Symfony\Component\Console\Application;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Console\Output\OutputInterface;

class CreateCommandWrapper extends CreateCommand
{
    protected function normalizeTarget() : Closure
    {
        return function(?string $v) : string {
            return "/home/test";
        };
    }

    protected function checkTarget() : Closure
    {
        return function(string $t) {
            if (! $this->filesystem->hasWriteAccess($t)) {
                throw new RuntimeException("the path '$t' is not writeable!");
            }
            return "/home/test";
        };
    }

    protected function getBranches(OutputInterface $output, string $path, string $url) : array
    {
        return ["foo"];
    }
}

class CreateCommandTest extends TestCase
{
    public function test_execute_with_empty_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Name of the instance cannot be empty!");
        $tester->execute(["--no-interaction" => true]);
    }

    public function test_execute_with_wrong_chars_in_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid characters! Only letters, numbers and underscores are allowed!");
        $tester->execute(["--no-interaction" => true, "--name" => "12$32"]);
    }

    public function test_execute_with_no_repo_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Repo can not be null!");
        $tester->execute(["--no-interaction" => true, "--name" => "1232"]);
    }

    public function test_execute_with_no_branch_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Branch can not be null!");
        $tester->execute(["--no-interaction" => true, "--name" => "1232", "--repo" => "foo"]);
    }

    public function test_execute_with_no_phpversion_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("PHP version can not be null!");
        $tester->execute(["--no-interaction" => true, "--name" => "1232", "--repo" => "foo", "--branch" => "foo"]);
    }

    public function test_execute_with_wrong_formatted_phpversion_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("PHP version must be formatted like *.* (7.4).");
        $tester->execute([
            "--no-interaction" => true,
            "--name" => "1232",
            "--repo" => "foo",
            "--branch" => "foo",
            "--phpversion" => "223.33"
        ]);
    }

    public function test_execute_with_non_existing_target() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $filesystem
            ->expects($this->once())
            ->method("getCurrentWorkingDirectory")
            ->willReturn("/home/test")
        ;
        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/test")
            ->willReturn(false)
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("the path '/home/test' does not exists!");
        $tester->execute([
            "--no-interaction" => true,
            "--name" => "1232",
            "--repo" => "foo",
            "--branch" => "foo",
            "--phpversion" => "2.3"
        ]);
    }

    public function test_execute_with_no_write_access_on_target() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommand(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $filesystem
            ->expects($this->once())
            ->method("getCurrentWorkingDirectory")
            ->willReturn("/home/test")
        ;
        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/test")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method("hasWriteAccess")
            ->with("/home/test")
            ->willReturn(false)
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("the path '/home/test' is not writeable!");
        $tester->execute([
            "--no-interaction" => true,
            "--name" => "1232",
            "--repo" => "foo",
            "--branch" => "foo",
            "--phpversion" => "2.3"
        ]);
    }

    public function test_execute_with_no_write_access_on_target_by_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = new CommandWriter();

        $command = new CreateCommandWrapper(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $filesystem
            ->expects($this->once())
            ->method("hasWriteAccess")
            ->with("/home/test")
            ->willReturn(false)
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("the path '/home/test' is not writeable!");
        $tester->execute([
            "--no-interaction" => true,
            "--name" => "1232",
            "--repo" => "foo",
            "--branch" => "foo",
            "--phpversion" => "2.3",
            "--target" => "/home/test"
        ]);
    }

    public function test_execute() : void
    {
        $docker = $this->createMock(Docker::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $git = $this->createMock(Git::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $linux = $this->createMock(Linux::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $writer = $this->createMock(Writer::class);

        $command = new CreateCommandWrapper(
            $docker,
            $repo_manager,
            $git,
            $posix,
            $filesystem,
            $linux,
            $project_config,
            $writer
        );
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $docker
            ->expects($this->once())
            ->method("getSaltAcceptedKeys")
            ->willReturn(["1232.local"])
        ;

        $filesystem
            ->expects($this->exactly(2))
            ->method("getLineInFile")
            ->withConsecutive(
                ["/etc/doil/doil.conf", "host"],
                ["/home/test/1232/volumes/ilias/include/inc.ilias_version.php", "ILIAS_VERSION_NUMERIC"]
            )
            ->willReturnOnConsecutiveCalls("foo=doil", "7.8")
        ;
        $filesystem
            ->expects($this->once())
            ->method("hasWriteAccess")
            ->with("/home/test")
            ->willReturn(true)
        ;

        $tester->execute([
            "--no-interaction" => true,
            "--name" => "1232",
            "--repo" => "foo",
            "--branch" => "foo",
            "--phpversion" => "2.3"
        ]);
    }
}