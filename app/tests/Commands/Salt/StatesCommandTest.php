<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Salt;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class StatesCommandTest extends TestCase
{
    public function test_execute() : void
    {
        $filesystem = $this->createMock(Filesystem::class);

        $command = new StatesCommand($filesystem);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("getFilesInPath")
            ->with("/usr/local/share/doil/stack/states")
            ->willReturn(["foo1", "foo2"])
        ;


        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "foo1\nfoo2\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }
}