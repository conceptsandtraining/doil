<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Config;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\FileNotFoundException;

class ConfigChecker
{
    public function __construct(
        protected Filesystem $filesystem
    ) {}

    public function check(Config $config) : void
    {
        if ($config->getHost() == '') {
            throw new \InvalidArgumentException('Host cannot be empty.');
        }

        if (!is_array($config->getAllowedHosts())) {
            throw new \InvalidArgumentException('AllowedHosts must be an array.');
        }

        if (!is_bool($config->getHttpsProxy())) {
            throw new \InvalidArgumentException('HttpsProxy must be a boolean.');
        }

        if ($config->getMailPassword() == '') {
            throw new \InvalidArgumentException('Mail password cannot be empty.');
        }

        if (!is_bool($config->isKeycloakEnabled())) {
            throw new \InvalidArgumentException('KeycloakEnabled must be a boolean.');
        }

        if ($config->getKeycloakHostname() == '') {
            throw new \InvalidArgumentException('KeycloakHostname cannot be empty.');
        }

        if ($config->getKeycloakNewAdminPassword() == '') {
            throw new \InvalidArgumentException('KeycloakNewAdminPassword cannot be empty.');
        }

        if ($config->getKeycloakOldAdminPassword() == '') {
            throw new \InvalidArgumentException('KeycloakOldAdminPassword cannot be empty.');
        }

        if ($config->getKeycloakDbUsername() == '') {
            throw new \InvalidArgumentException('KeycloakDbUsername cannot be empty.');
        }

        if ($config->getKeycloakDbPassword() == '') {
            throw new \InvalidArgumentException('KeycloakDbPassword cannot be empty.');
        }

        if (!is_string($config->getUpdateToken())) {
            throw new \InvalidArgumentException('UpdateToken must be a string.');
        }

        if ($config->getGitPrivateSSHKeyPath() == '') {
            throw new \InvalidArgumentException('GitPrivateSSHKeyPath cannot be empty.');
        }

        if ($config->getGitPublicSSHKeyPath() == '') {
            throw new \InvalidArgumentException('GitPublicSSHKeyPath cannot be empty.');
        }

        if (! $this->filesystem->exists($config->getGitPrivateSSHKeyPath())) {
            throw new FileNotFoundException("Cannot locate GitPrivateSSHKey.");
        }

        if (! $this->filesystem->exists($config->getGitPublicSSHKeyPath())) {
            throw new FileNotFoundException("Cannot locate GitPublicSSHKey.");
        }
    }
}