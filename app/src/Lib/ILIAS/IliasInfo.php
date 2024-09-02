<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\ILIAS;

use RuntimeException;
use CaT\Doil\Lib\FileSystem\Filesystem;

class IliasInfo implements ILIAS
{
    protected Filesystem $filesystem;

    public function __construct(
        Filesystem $filesystem
    ) {
        $this->filesystem = $filesystem;
    }

    public function getIliasVersion(string $path) : string
    {
        if ($this->filesystem->exists($path . "/volumes/ilias/include/inc.ilias_version.php")) {
            $ilias_version_path = $path . "/volumes/ilias/include/inc.ilias_version.php";
        } else if ($this->filesystem->exists($path . "/volumes/ilias/ilias_version.php")) {
            $ilias_version_path = $path . "/volumes/ilias/ilias_version.php";
        } else {
            throw new RuntimeException("Can't detect ilias version!");
        }

        $ilias_version = $this->filesystem->getLineInFile(
            $ilias_version_path,
            "ILIAS_VERSION_NUMERIC"
        );

        preg_match("/\d+.\d/", $ilias_version, $version);

        return $version[0];
    }
}