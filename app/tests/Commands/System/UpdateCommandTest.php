<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\System;

use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\System\Update;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Application;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class UpdateCommandTest extends TestCase
{
    public function test_execute_as_non_root() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $git  = $this->createMock(Git::class);
        $update = $this->createMock(Update::class);
        $writer = new CommandWriter();

        $command = new UpdateCommand($posix, $filesystem, $git, $update, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method('isSudo')
            ->willReturn(false)
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Error:\n\tPlease execute this script as sudo user!\n\t\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_nothing_to_do() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $git  = $this->createMock(Git::class);
        $update = $this->createMock(Update::class);
        $writer = new CommandWriter();

        $command = new UpdateCommand($posix, $filesystem, $git, $update, $writer);
        $tester = new CommandTester($command);

        $posix
            ->expects($this->once())
            ->method('isSudo')
            ->willReturn(true)
        ;

        $filesystem
            ->expects($this->once())
            ->method('getLineInFile')
            ->with("/usr/local/lib/doil/app/src/App.php", "Doil Version")
            ->willReturn("const NAME = \"Doil Version 20251101 - build 2025-11-01\";")
        ;

        $git
            ->expects($this->once())
            ->method('getTagsFromGithubUrl')
            ->with("https://github.com/conceptsandtraining/doil.git")
            ->willReturn(["20251005", "20251010", "20250920"])
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Current version: 20251101\nNothing to do. Everything is up to date!\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }

    public function test_execute_no_confirm() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $git  = $this->createMock(Git::class);
        $update = $this->createMock(Update::class);
        $writer = new CommandWriter();

        $command = new UpdateCommand($posix, $filesystem, $git, $update, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $posix
            ->expects($this->once())
            ->method('isSudo')
            ->willReturn(true)
        ;

        $filesystem
            ->expects($this->once())
            ->method('getLineInFile')
            ->with("/usr/local/lib/doil/app/src/App.php", "Doil Version")
            ->willReturn("Doil Version 20251101 - build 2025-11-01")
        ;

        $git
            ->expects($this->once())
            ->method('getTagsFromGithubUrl')
            ->with("https://github.com/conceptsandtraining/doil.git")
            ->willReturn(["20261005", "20261010", "20260920"])
        ;

        $tester->setInputs(['no']);
        $execute_result = $tester->execute([]);

        $this->assertEquals(1, $execute_result);
    }

    public function test_execute_yes_confirm() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $git  = $this->createMock(Git::class);
        $update = $this->createMock(Update::class);
        $writer = new CommandWriter();

        $command = new UpdateCommand($posix, $filesystem, $git, $update, $writer);
        $tester = new CommandTester($command);
        $app = new Application("doil");
        $command->setApplication($app);

        $posix
            ->expects($this->once())
            ->method('isSudo')
            ->willReturn(true)
        ;

        $filesystem
            ->expects($this->once())
            ->method('getLineInFile')
            ->with("/usr/local/lib/doil/app/src/App.php", "Doil Version")
            ->willReturn("Doil Version 20251101 - build 2025-11-01")
        ;

        $git
            ->expects($this->once())
            ->method('getTagsFromGithubUrl')
            ->with("https://github.com/conceptsandtraining/doil.git")
            ->willReturn(["20261005", "20261010", "20260920"])
        ;

        $update
            ->expects($this->once())
            ->method('run')
            ->with("https://github.com/conceptsandtraining/doil.git", ["20261005", "20261010", "20260920"])
        ;

        $tester->setInputs(['yes']);
        $execute_result = $tester->execute([]);


        $this->assertEquals(0, $execute_result);
    }
}
