<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\CopyFiles;

use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOException;

class Copy
{
    protected const SERVER = [
        "mail",
        "proxy",
        "salt"
    ];

    protected const TEMPLATES = [
        "minion",
        "base"
    ];

    public function __construct(
        protected FileSystem $fileSystemShell
    ) {}

    /**
     * @throws IOException
     */
    public function copyDoil(string $base_path, Config $config) : void
    {
        if ($config->isKeycloakEnabled()) {
            $this->fileSystemShell->copyDirectory(
                $base_path . "/app/src/Setup/templates/keycloak",
                "/usr/local/lib/doil/server/keycloak"
            );
        }
        foreach (self::SERVER as $server) {
            $this->fileSystemShell->copyDirectory(
                $base_path . "/app/src/Setup/templates/$server",
                "/usr/local/lib/doil/server/$server"
            );
        }

        foreach (self::TEMPLATES as $template) {
            $this->fileSystemShell->copyDirectory(
                $base_path . "/app/src/Setup/templates/$template",
                "/usr/local/share/doil/templates/$template"
            );
        }

        $this->fileSystemShell->copy(
            $base_path . "/setup/Dockerfile",
            "/usr/local/lib/doil/server/php/Dockerfile"
        );

        $this->fileSystemShell->copy(
            $base_path . "/app/src/Setup/doil.sh",
            "/usr/local/bin/doil"
        );

        $this->fileSystemShell->copyDirectory(
            $base_path . "/app",
            "/usr/local/lib/doil/app"
        );

        $this->fileSystemShell->copyDirectory(
            $base_path . "/app/src/Setup/stack",
            "/usr/local/share/doil/stack"
        );

        if ($this->fileSystemShell->exists("/usr/local/lib/doil/app/composer.lock")) {
            $this->fileSystemShell->remove("/usr/local/lib/doil/app/composer.lock");
        }
    }
}