<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use RuntimeException;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class DeleteCommandTest extends TestCase
{
    public function test_execute_without_name_and_all() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($repo_manager, $writer);
        $tester = new CommandTester($command);

        $this->expectException(InvalidArgumentException::class);
        $tester->execute([]);
    }

    public function test_execute_with_empty_name() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($repo_manager, $writer);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Name of the repo cannot be empty!");
        $execute_result = $tester->execute(["name" => ""]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_wrong_chars_in_name() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($repo_manager, $writer);
        $tester = new CommandTester($command);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage("Invalid characters! Only letters, numbers and underscores are allowed!");
        $execute_result = $tester->execute(["name" => "3209§09klj"]);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_with_non_existing_repo() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = new CommandWriter();

        $command = new DeleteCommand($repo_manager, $writer);
        $tester = new CommandTester($command);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;
        $repo = new Repo("doil");
        $repo_manager
            ->expects($this->once())
            ->method("repoNameExists")
            ->with($repo)
            ->willReturn(false)
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tRepository doil does not exists!\n\tUse doil repo:list to see current installed repos.\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $writer = $this->createMock(Writer::class);

        $command = new DeleteCommand($repo_manager, $writer);
        $tester = new CommandTester($command);

        $repo_manager
            ->expects($this->once())
            ->method("getEmptyRepo")
            ->willReturn(new Repo())
        ;
        $repo = new Repo("doil");
        $repo_manager
            ->expects($this->once())
            ->method("repoNameExists")
            ->with($repo)
            ->willReturn(true)
        ;
        $repo_manager
            ->expects($this->once())
            ->method("deleteRepo")
            ->with($repo)
        ;

        $execute_result = $tester->execute(["name" => "doil"]);
        $this->assertEquals(0, $execute_result);
    }
}