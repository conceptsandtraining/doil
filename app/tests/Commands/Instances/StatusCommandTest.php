<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Docker\Docker;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Console\Tester\CommandTester;

class StatusCommandTest extends TestCase
{
    public function testExecute() : void
    {
        $docker = $this->createMock(Docker::class);
        $command = new StatusCommand($docker);
        $tester = new CommandTester($command);

        $docker
            ->expects($this->once())
            ->method("ps")
            ->willReturn(["doil_mail", "doil/master_local", "doil/ilias7_global", "ilias8", "trunk"])
        ;

        $tester->execute([]);
        $output = $tester->getDisplay(true);

        $this->assertStringContainsString("doil_mail", $output);
        $this->assertStringContainsString("doil/master_local", $output);
        $this->assertStringContainsString("doil/ilias7_global", $output);
        $this->assertStringNotContainsString("ilias8", $output);
        $this->assertStringNotContainsString("trunk", $output);
    }
}