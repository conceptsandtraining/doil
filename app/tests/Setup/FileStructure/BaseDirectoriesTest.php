<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\FileStructure;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOException;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class BaseDirectoriesTest extends TestCase
{
    public function test_createBaseDirs_positive() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_directories = new BaseDirectories($filesystem, $home_dir, $user_name);

        $filesystem
            ->expects($this->exactly(14))
            ->method("makeDirectoryRecursive")
            ->willReturn(true)
        ;

        $base_directories->createBaseDirs();
    }

    public function test_createBaseDirs_negative() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_directories = new BaseDirectories($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(3);
        $filesystem
            ->expects($matcher)
            ->method("makeDirectoryRecursive")
            ->willReturnCallback(function () use ($matcher) {
                return match ($matcher->numberOfInvocations()) {
                    1, 2 => true,
                    3 => false
                };
            })
        ;

        $this->expectException(IOException::class);
        $base_directories->createBaseDirs();
    }

    public function test_setOwnerGroupForBaseDirs() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_directories = new BaseDirectories($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(12);
        $filesystem
            ->expects($matcher)
            ->method("chownRecursive")
            ->willReturnCallback(function () use ($matcher, $home_dir, $user_name) {
                match ($matcher->numberOfInvocations()) {
                    1 => [$home_dir . "/.doil/" . $user_name, $user_name],
                    2 => ["/usr/local/lib/doil", "root", "doil"],
                    3 => ["/usr/local/lib/doil/server", "root", "doil"],
                    4 => ["/usr/local/lib/doil/server/php", "root", "doil"],
                    5 => ["/usr/local/share/doil", "root", "doil"],
                    6 => ["/usr/local/share/doil/templates", "root", "doil"],
                    7 => ["/etc/doil", "root", "doil"],
                    8 => ["/srv/instances", "root", "doil"],
                    9 => ["/usr/local/lib/doil/app", "root", "doil"],
                    10 => ["/usr/local/share/doil/instances", "root", "doil"],
                    11 => ["/usr/local/share/doil/repositories", "root", "doil"],
                    12 => ["/var/log/doil", "root", "doil"]
                };
            })
        ;

        $base_directories->setOwnerGroupForBaseDirs();
    }

    public function test_setFilePermissionsForBaseDirs() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_directories = new BaseDirectories($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(12);
        $filesystem
            ->expects($matcher)
            ->method("chmod")
            ->willReturnCallback(function () use ($matcher, $home_dir) {
                match ($matcher->numberOfInvocations()) {
                    1 => [$home_dir . "/.doil/", 0775],
                    2 => ["/usr/local/lib/doil", 0775],
                    3 => ["/usr/local/lib/doil/server", 0775],
                    4 => ["/usr/local/lib/doil/server/php", 0775],
                    5 => ["/usr/local/share/doil", 0775],
                    6 => ["/usr/local/share/doil/templates", 0775],
                    7 => ["/etc/doil", 02775],
                    8 => ["/srv/instances", 02775],
                    9 => ["/usr/local/lib/doil/app", 02775],
                    10 => ["/usr/local/share/doil/instances", 02775],
                    11 => ["/usr/local/share/doil/repositories", 02775],
                    12 => ["/var/log/doil", 02775]
                };
            })
        ;

        $base_directories->setFilePermissionsForBaseDirs();
    }
}