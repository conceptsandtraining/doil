<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use InvalidArgumentException;
use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Console\Output\OutputInterface;

class CommandWriterWrapper extends CommandWriter
{
    public function beginBlock(OutputInterface $output, string $txt) : void
    {
    }

    public function endBlock() : void
    {
    }

    public function error(OutputInterface $output, string $msg, string $hint = "") : void
    {
    }
}

class CSPCommandWrapper extends CSPCommand
{
    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        return true;
    }
}

class CSPCommandTest extends TestCase
{
    public function test_execute_with_no_instance_no_all() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);

        $command = new CSPCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $this->expectException(InvalidArgumentException::class);
        $tester->execute([]);
    }

    public function test_execute_with_no_docker_compose_file() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = $this->createMock(Writer::class);

        $command = new CSPCommand($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Can't find a suitable docker-compose.yml file in /usr/local/share/doil/instances/12hvee2345ns");
        $tester->execute(["instance" => "12hvee2345ns", "-g" => true]);
    }

    public function test_execute_single() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriterWrapper();

        $command = new CSPCommandWrapper($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("isInstanceUp")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->once())
            ->method("setGrain")
            ->with("12hvee2345ns.global", "csp", "csp_rule")
        ;
        $docker
            ->expects($this->once())
            ->method("applyState")
            ->with("12hvee2345ns.global", "apache")
        ;

        $tester->execute(["instance" => "12hvee2345ns", "-g" => true, "--rules" => "csp_rule"]);
    }

    public function test_execute_all_without_instances() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriterWrapper();

        $command = new CSPCommandWrapper($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("getFilesInPath")
            ->with("/usr/local/share/doil/instances")
            ->willReturn([])
        ;

        $result = $tester->execute(["-a" => true, "-g" => true, "--rules" => "csp_rule"]);
        $this->assertEquals(1, $result);
    }

    public function test_execute_all() : void
    {
        $docker = $this->createMock(Docker::class);
        $posix = $this->createMock(Posix::class);
        $filesystem = $this->createMock(Filesystem::class);
        $writer = new CommandWriterWrapper();

        $command = new CSPCommandWrapper($docker, $posix, $filesystem, $writer);
        $tester = new CommandTester($command);

        $filesystem
            ->expects($this->once())
            ->method("getFilesInPath")
            ->with("/usr/local/share/doil/instances")
            ->willReturn(["12hvee2345ns", "dkk334kkaa"])
        ;

        $docker
            ->expects($this->exactly(2))
            ->method("isInstanceUp")
            ->willReturn(true)
        ;
        $docker
            ->expects($this->exactly(2))
            ->method("setGrain")
            ->willReturnOnConsecutiveCalls(
                ["12hvee2345ns.global", "csp", "csp_rule"],
                ["dkk334kkaa.global", "csp", "csp_rule"],
            )
        ;
        $docker
            ->expects($this->exactly(2))
            ->method("applyState")
            ->willReturnOnConsecutiveCalls(
                ["12hvee2345ns.global", "apache"],
                ["dkk334kkaa.global", "apache"],
            )
        ;

        $tester->execute(["-a" => true, "-g" => true, "--rules" => "csp_rule"]);
    }
}