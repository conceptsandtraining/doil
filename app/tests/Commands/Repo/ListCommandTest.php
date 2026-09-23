<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use PHPUnit\Framework\TestCase;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class ListCommandTest extends TestCase
{
    public function test_execute() : void
    {
        $repo_manager = $this->createMock(RepoManager::class);
        $command = new ListCommand($repo_manager);
        $tester = new CommandTester($command);

        $local1 = new Repo("local1", "http://test/doil.git");
        $local2 = new Repo("local2", "http://test/doil.git");
        $global1 = new Repo("global1", "http://test/doil.git", true);
        $global2 = new Repo("global2", "http://test/doil.git", true);

        $repo_manager
            ->expects($this->once())
            ->method("getLocalRepos")
            ->willReturn([$local1, $local2])
        ;
        $repo_manager
            ->expects($this->once())
            ->method("getGlobalRepos")
            ->willReturn([$global1, $global2])
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Currently registered local repositories:\n";
        $result .= "\tlocal1 - http://test/doil.git\n";
        $result .= "\tlocal2 - http://test/doil.git\n";
        $result .= "\n";
        $result .= "Currently registered global repositories:\n";
        $result .= "\tglobal1 - http://test/doil.git\n";
        $result .= "\tglobal2 - http://test/doil.git\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }
}