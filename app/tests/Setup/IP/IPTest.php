<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\IP;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Lib\FileSystem\Filesystem;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class IPTest extends TestCase
{
    public function test_setIPToHosts_Exception() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $config = $this->createMock(Config::class);

        $ip = new IP($filesystem);

        $filesystem
            ->expects($this->once())
            ->method('getLineInFile')
            ->with("/etc/hosts", IP::IP)
            ->willReturn("foobar")
        ;

        $this->expectException(\RuntimeException::class);
        $ip->setIPToHosts($config);
    }

    public function test_setIPToHosts() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $config = $this->createMock(Config::class);

        $ip = new IP($filesystem);

        $filesystem
            ->expects($this->once())
            ->method('getLineInFile')
            ->with("/etc/hosts", IP::IP)
            ->willReturn(null)
        ;

        $config
            ->expects($this->once())
            ->method('getHost')
            ->willReturn("foobar")
        ;

        $filesystem
            ->expects($this->once())
            ->method('setContent')
            ->with("/etc/hosts", IP::IP . " foobar\n", true)
        ;

        $ip->setIPToHosts($config);
    }
}