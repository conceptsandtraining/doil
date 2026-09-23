<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\FileStructure;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\FileSystem\Filesystem;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class BaseFilesTest extends TestCase
{
    public function test_createBaseDirs_positive() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_files = new BaseFiles($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(3);
        $filesystem
            ->expects($matcher)
            ->method("touch")
            ->willReturnCallback(function () use ($matcher, $home_dir) {
                match ($matcher->numberOfInvocations()) {
                    1 => ["/etc/doil/repositories.json"],
                    2 => ["/etc/doil/user.json"],
                    3 => [$home_dir . "/.doil/config/repositories.json"]
                };
            })
        ;

        $base_files->touchFiles();
    }

    public function test_setDefaultUser() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_files = new BaseFiles($filesystem, $home_dir, $user_name);

        $filesystem
            ->expects($this->once())
            ->method("setContent")
            ->with(
                "/etc/doil/user.json",
                '"a:1:{i:0;O:27:\"CaT\\\\Doil\\\\Commands\\\\User\\\\User\":1:{s:7:\"\u0000*\u0000name\";s:' . strlen($user_name) . ':\"' . $user_name . '\";}}"'
            )
        ;

        $base_files->setDefaultUser();
    }

    public function test_setDefaultRepository() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_files = new BaseFiles($filesystem, $home_dir, $user_name);

        $filesystem
            ->expects($this->once())
            ->method("setContent")
            ->with(
                "/etc/doil/repositories.json",
                '"a:1:{i:1;O:27:\"CaT\\\\Doil\\\\Commands\\\\Repo\\\\Repo\":3:{s:7:\"\u0000*\u0000name\";s:5:\"ilias\";s:6:\"\u0000*\u0000url\";s:44:\"https:\\/\\/github.com\\/ILIAS-eLearning\\/ILIAS.git\";s:9:\"\u0000*\u0000global\";b:1;}}"'
            )
        ;

        $base_files->setDefaultRepository();
    }

    public function test_setFilePermissionsForBaseFiles() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_files = new BaseFiles($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(2);
        $filesystem
            ->expects($matcher)
            ->method("chmod")
            ->willReturnCallback(function () use ($matcher, $home_dir) {
                match ($matcher->numberOfInvocations()) {
                    1 => ["/etc/doil/repositories.json", 0664],
                    2 => ["/etc/doil/user.json", 0664]
                };
            })
        ;

        $base_files->setFilePermissionsForBaseFiles();
    }

    public function test_setFileOwner() : void
    {
        $filesystem = $this->createMock(Filesystem::class);
        $home_dir = "/home/test";
        $user_name = "doil";

        $base_files = new BaseFiles($filesystem, $home_dir, $user_name);

        $matcher = $this->exactly(1);
        $filesystem
            ->expects($matcher)
            ->method("chownRecursive")
            ->willReturnCallback(function () use ($matcher, $home_dir, $user_name) {
                match ($matcher->numberOfInvocations()) {
                    1 => [$home_dir . "/.doil/config/repositories.json", $user_name, $user_name]
                };
            })
        ;

        $base_files->setFileOwner();
    }
}