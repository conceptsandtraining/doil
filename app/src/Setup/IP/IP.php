<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\IP;

use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Lib\FileSystem\Filesystem;

class IP
{
    public const IP = "172.24.0.254";

    public function __construct(
        protected Filesystem $filesystem
    ) {}

    /**
     * @throws \RuntimeException
     */
    public function setIPToHosts(Config $config) : int|bool
    {
        if (!is_null($this->filesystem->getLineInFile("/etc/hosts", self::IP))) {
            throw new \RuntimeException("IP " . self::IP . " already set!");
        }

        $line = self::IP . " " . $config->getHost() . "\n";

        return $this->filesystem->setContent("/etc/hosts", $line, true);
    }
}