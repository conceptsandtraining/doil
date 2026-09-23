<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\FileStructure;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOException;

class BaseFiles
{
    protected const GLOBAL_FILES = [
        "/etc/doil/repositories.json",
        "/etc/doil/user.json"
    ];

    protected const USER_FILES = [
        ".doil/config/repositories.json"
    ];

    protected string $home_dir;
    protected string $user_name;

    public function __construct(
        protected FileSystem $fileSystemShell,
        string $home_dir,
        string $user_name,
    ) {
        $this->home_dir = $home_dir;
        $this->user_name = $user_name;
    }

    /**
     * @throws IOException
     */
    public function touchFiles() : void
    {
        foreach (self::GLOBAL_FILES as $file) {
            $this->fileSystemShell->touch($file);
        }

        foreach (self::USER_FILES as $file) {
            $this->fileSystemShell->touch($this->home_dir . "/" . $file);
        }
    }

    public function setDefaultUser() : int|bool
    {
        return $this->fileSystemShell->setContent(
            "/etc/doil/user.json",
            '"a:1:{i:0;O:27:\"CaT\\\\Doil\\\\Commands\\\\User\\\\User\":1:{s:7:\"\u0000*\u0000name\";s:' . strlen($this->user_name) . ':\"' . $this->user_name . '\";}}"'
        );
    }

    public function setDefaultRepository() : int|bool
    {
        return $this->fileSystemShell->setContent(
            "/etc/doil/repositories.json",
            '"a:1:{i:1;O:27:\"CaT\\\\Doil\\\\Commands\\\\Repo\\\\Repo\":3:{s:7:\"\u0000*\u0000name\";s:5:\"ilias\";s:6:\"\u0000*\u0000url\";s:44:\"https:\\/\\/github.com\\/ILIAS-eLearning\\/ILIAS.git\";s:9:\"\u0000*\u0000global\";b:1;}}"'
        );
    }

    public function setFilePermissionsForBaseFiles() : void
    {
        foreach (self::GLOBAL_FILES as $file) {
            $this->fileSystemShell->chmod($file, 0664);
        }
    }

    public function setFileOwner() : void
    {
        foreach (self::USER_FILES as $file) {
            $this->fileSystemShell->chownRecursive($this->home_dir . "/" . $file, $this->user_name, $this->user_name);
        }
    }
}