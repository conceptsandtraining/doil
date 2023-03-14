<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use RuntimeException;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Application;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;

class AddCommandTest extends TestCase
{
    public function test_execute_without_name() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $execute_result = $tester->execute(["--no-interaction" => true, "--url" => "https://test/doil"]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_without_url() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $this->expectException(RuntimeException::class);
        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil"]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_wrong_chars_in_file_name() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid characters! Only letters, numbers and underscores are allowed!");

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "33%sj", "--url" => "https://test/doil"]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_empty_url() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Url of the repo cannot be empty!");

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil", "--url" => ""]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_wrong_url() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid github url.");

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil", "--url" => "fail"]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_already_existing_repo_url() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;
        $repo = new Repo("doil", "https://test/doil.git", false);
        $repo_manager
            ->expects($this->once())
            ->method("repoUrlExists")
            ->with($repo)
            ->willReturn(true)
        ;

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil", "--url" => "https://test/doil.git"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tRepository with url 'https://test/doil.git' already exists!\n\tUse doil repo:list to see current installed repos.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_already_existing_repo_name() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;
        $repo = new Repo("doil", "https://test/doil.git", false);
        $repo_manager
            ->expects($this->once())
            ->method("repoNameExists")
            ->with($repo)
            ->willReturn(true)
        ;

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil", "--url" => "https://test/doil.git"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tRepository with name 'doil' already exists!\n\tUse doil repo:list to see current installed repos.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new AddCommand($repo_manager, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;
        $repo = new Repo("doil", "https://test/doil.git", false);
        $repo_manager
            ->expects($this->once())
            ->method("repoUrlExists")
            ->with($repo)
            ->willReturn(false)
        ;
        $repo_manager
            ->expects($this->once())
            ->method("repoNameExists")
            ->with($repo)
            ->willReturn(false)
        ;
        $repo_manager
            ->expects($this->once())
            ->method("addRepo")
            ->with($repo)
        ;

        $execute_result = $tester->execute(["--no-interaction" => true, "--name" => "doil", "--url" => "https://test/doil.git"]);
        $this->assertEquals(0, $execute_result);
    }
}