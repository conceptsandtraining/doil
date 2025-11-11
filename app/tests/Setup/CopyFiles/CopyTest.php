<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\CopyFiles;

use PHPUnit\Framework\TestCase;
use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Lib\FileSystem\Filesystem;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class CopyTest extends TestCase
{
    public function test_copyDoil() : void
    {
        $base_path = "/tmp/foo";
        $filesystem = $this->createMock(Filesystem::class);
        $config = $this->createMock(Config::class);

        $copy = new Copy($filesystem);

        $config
            ->expects($this->once())
            ->method('isKeycloakEnabled')
            ->willReturn(true)
        ;

        $matcher = $this->exactly(8);
        $filesystem
            ->expects($matcher)
            ->method('copyDirectory')
            ->willReturnCallback(function () use ($matcher, $base_path) {
                match ($matcher->numberOfInvocations()) {
                    1 => [$base_path . "/app/src/Setup/templates/keycloak", "/usr/local/lib/doil/server/keycloak"],
                    2 => [$base_path . "/app/src/Setup/templates/mail", "/usr/local/lib/doil/server/mail"],
                    3 => [$base_path . "/app/src/Setup/templates/proxy", "/usr/local/lib/doil/server/proxy"],
                    4 => [$base_path . "/app/src/Setup/templates/salt", "/usr/local/lib/doil/server/salt"],
                    5 => [$base_path . "/app/src/Setup/templates/minion", "/usr/local/share/doil/templates/minion"],
                    6 => [$base_path . "/app/src/Setup/templates/base", "/usr/local/share/doil/templates/base"],
                    7 => [$base_path . "/app", "/usr/local/lib/doil/app"],
                    8 => [$base_path . "/app/src/Setup/stack", "/usr/local/share/doil/stack"]
                };
            })
        ;

        $matcher = $this->exactly(2);
        $filesystem
            ->expects($matcher)
            ->method('copy')
            ->willReturnCallback(function () use ($matcher, $base_path) {
                match ($matcher->numberOfInvocations()) {
                    1 => [$base_path . "/setup/Dockerfile", "/usr/local/lib/doil/server/php/Dockerfile"],
                    2 => [$base_path . "/app/src/Setup/doil.sh", "/usr/local/bin/doil"]
                };
            })
        ;

        $filesystem
            ->expects($this->once())
            ->method('exists')
            ->with("/usr/local/lib/doil/app/composer.lock")
            ->willReturn(true)
        ;
        $filesystem
            ->expects($this->once())
            ->method('remove')
            ->with("/usr/local/lib/doil/app/composer.lock")
        ;

        $copy->copyDoil($base_path, $config);

    }
}