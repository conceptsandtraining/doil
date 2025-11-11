<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Config;

use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Filesystem\Exception\FileNotFoundException;

class ConfigReader
{
    protected const CONFIG_PATH = "/etc/doil";

    public function __construct(
        protected Config $config,
        protected Filesystem $filesystem,
    ) {}

    /**
     * @throws FileNotFoundException
     */
    public function getConfig(): Config
    {
        if (!$this->filesystem->exists(self::CONFIG_PATH . "/doil.conf")) {
            throw new FileNotFoundException("Config file not found at: " . self::CONFIG_PATH . "/doil.conf");
        }

        $ini = $this->filesystem->parseIniFile(self::CONFIG_PATH . "/doil.conf");

        $this->config = $this->config
            ->withHost($ini["host"])
            ->withAllowedHosts(explode(",", $ini["allowed_hosts"]))
            ->withHttpsProxy($ini["https_proxy"])
            ->withMailPassword($ini["mail_password"])
            ->withEnableKeycloak($ini["keycloak_enabled"])
            ->withKeycloakHostname($ini["keycloak_hostname"])
            ->withKeycloakNewAdminPassword($ini["keycloak_new_admin_password"])
            ->withKeycloakOldAdminPassword($ini["keycloak_old_admin_password"])
            ->withKeycloakDbUsername($ini["keycloak_db_username"])
            ->withKeycloakDbPassword($ini["keycloak_db_password"])
            ->withUpdateToken($ini["update_token"])
            ->withGitPrivateSSHKeyPath($ini["git_private_ssh_key_path"])
            ->withGitPublicSSHKeyPath($ini["git_public_ssh_key_path"])
        ;

        return $this->config;
    }

    public function writeToFile() : bool
    {
        $this->filesystem->makeDirectoryRecursive(self::CONFIG_PATH);
        if (file_put_contents(self::CONFIG_PATH."/doil.conf~", $this->config, 0, null) !== false) {
            return rename(self::CONFIG_PATH . "/doil.conf~", self::CONFIG_PATH . "/doil.conf", null);
        }

        @unlink(self::CONFIG_PATH."/doil.conf~");
        return false;
    }
}