<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Pack;

use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Lib\ILIAS\IliasInfo;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class ExportCommandTest extends TestCase
{
    public function test_execute_without_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $git = $this->createMock(Git::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ExportCommand(
            $docker,
            $posix,
            $filesystem,
            $writer,
            $project_config,
            $git,
            $repo_manager,
            $ilias_info
        );
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Not enough arguments (missing: \"instance\").");
        $tester->execute([]);
    }

    public function test_execute_with_empty_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $git = $this->createMock(Git::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ExportCommand(
            $docker,
            $posix,
            $filesystem,
            $writer,
            $project_config,
            $git,
            $repo_manager,
            $ilias_info
        );
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Name of the instance cannot be empty!");
        $tester->execute(["instance" => ""]);
    }

    public function test_execute_with_wrong_chars_in_instance_param() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $git = $this->createMock(Git::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ExportCommand(
            $docker,
            $posix,
            $filesystem,
            $writer,
            $project_config,
            $git,
            $repo_manager,
            $ilias_info
        );
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid characters! Only letters and numbers are allowed!");
        $tester->execute(["instance" => "Foo§Bar"]);
    }

    public function test_execute_with_no_docker_compose_file() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $project_config = $this->createMock(ProjectConfig::class);
        $git = $this->createMock(Git::class);
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();
        $ilias_info = $this->createMock(IliasInfo::class);

        $command = new ExportCommand(
            $docker,
            $posix,
            $filesystem,
            $writer,
            $project_config,
            $git,
            $repo_manager,
            $ilias_info
        );
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

        $execute_result = $tester->execute(["instance" => "foo1"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n";
        $result .= "\tCan't find a suitable docker-compose file in this directory '/home/doil/.doil/instances/foo1'.\n";
        $result .= "\tIs this the right directory?\n";
        $result .= "\tSupported filenames: docker-compose.yml\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }
}