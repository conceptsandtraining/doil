<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\FileStructure;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOException;

class BaseDirectories
{
    protected const USER_PATHS = [
        ".doil/config",
        ".doil/repositories",
        ".doil/instances"
    ];

    protected const PATHS = [
        "/usr/local/lib/doil",
        "/usr/local/lib/doil/server",
        "/usr/local/lib/doil/server/php",
        "/usr/local/share/doil",
        "/usr/local/share/doil/templates",
    ];

    protected const SUPER_BIT_PATHS = [
        "/etc/doil",
        "/srv/instances",
        "/usr/local/lib/doil/app",
        "/usr/local/share/doil/instances",
        "/usr/local/share/doil/repositories",
        "/var/log/doil",
    ];

    public function __construct(
        protected FileSystem $file_system,
        protected string $home_dir,
        protected string $user_name,
    ) {}

    public function createBaseDirs() : void
    {
        foreach (self::USER_PATHS as $path) {
            if (! $this->file_system->makeDirectoryRecursive($this->home_dir . "/" . $path)) {
                throw new IOException("Unable to create directory " . $this->home_dir . "/" . $path);
            }
        }

        foreach (self::PATHS as $path) {
            if (! $this->file_system->makeDirectoryRecursive($path)) {
                throw new IOException("Unable to create directory " . $path);
            }
        }

        foreach (self::SUPER_BIT_PATHS as $path) {
            if (! $this->file_system->makeDirectoryRecursive($path)) {
                throw new IOException("Unable to create directory " . $path);
            }
        }
    }

    public function setOwnerGroupForBaseDirs() : void
    {
        $this->file_system->chownRecursive($this->home_dir . "/.doil", $this->user_name, $this->user_name);

        foreach (self::PATHS as $path) {
            $this->file_system->chownRecursive($path, "root", "doil");
        }

        foreach (self::SUPER_BIT_PATHS as $path) {
            $this->file_system->chownRecursive($path, "root", "doil");
        }
    }

    public function setFilePermissionsForBaseDirs() : void
    {
        $this->file_system->chmod($this->home_dir . "/.doil", 0775);

        foreach (self::PATHS as $path) {
            $this->file_system->chmod($path, 0775);
        }

        foreach (self::SUPER_BIT_PATHS as $path) {
            $this->file_system->chmod($path, 02775);
        }
    }
}