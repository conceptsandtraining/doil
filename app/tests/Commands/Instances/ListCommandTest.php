<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class ListCommandTest extends TestCase
{
    public function test_execute_with_non_existing_local_dir() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();

        $command = new ListCommand($posix, $filesystem, $writer);
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

        $filesystem
            ->expects($this->once())
            ->method("exists")
            ->with("/home/doil/.doil/instances")
            ->willReturn(false)
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Currently registered local instances:\nError:\n\tDirectory '/home/doil/.doil/instances' doesn't exist. Please check your 'doil' installation.\n\t\n";
        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);

    }

    public function test_execute_with_non_existing_global_dir() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriter();

        $command = new ListCommand($posix, $filesystem, $writer);
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

        $matcher = $this->exactly(2);
        $filesystem
            ->expects($matcher)
            ->method("exists")
            ->willReturnCallback(function (string $value) use ($matcher) {
                return match ($matcher->numberOfInvocations()) {
                    1 => $value == "/home/doil/.doil/instances",
                    2 => $value != "/usr/local/share/doil/instances",
                };
            })
        ;
        $filesystem
            ->expects($this->once())
            ->method("getFilesInPath")
            ->with("/home/doil/.doil/instances")
            ->willReturn(["local1", "local2", "local3"])
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Currently registered local instances:\nlocal1\nlocal2\nlocal3\n";
        $result .= "\n";
        $result .= "Currently registered global instances:\n";
        $result .= "Error:\n\tDirectory '/usr/local/share/doil/instances' doesn't exist. Please check your 'doil' installation.\n\t\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(1, $execute_result);
    }

    public function test_execute() : void
    {
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);

        $command = new ListCommand($posix, $filesystem, $writer);
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

        $matcher = $this->exactly(2);
        $filesystem
            ->expects($matcher)
            ->method("exists")
            ->willReturnCallback(function (string $value) use ($matcher) {
                return match ($matcher->numberOfInvocations()) {
                    1 => $value == "/home/doil/.doil/instances",
                    2 => $value == "/usr/local/share/doil/instances",
                };
            })
        ;
        $matcher = $this->exactly(2);
        $filesystem
            ->expects($matcher)
            ->method("getFilesInPath")
            ->willReturnCallback(function () use ($matcher) {
                return match ($matcher->numberOfInvocations()) {
                    1 => ["local1", "local2", "local3"],
                    2 => ["global1", "global2"],
                };
            })
        ;

        $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Currently registered local instances:\nlocal1\nlocal2\nlocal3\n\nCurrently registered global instances:\nglobal1\nglobal2\n";

        $this->assertEquals($result, $output);
    }
}