<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Config;

class Config
{
    public function __construct(
        protected string $host = "doil",
        protected array $allowed_hosts = [],
        protected bool $https_proxy  = false,
        protected string $mail_password = "ilias",
        protected bool $keycloak_enabled = false,
        protected string $keycloak_hostname = "http://doil/keycloak",
        protected string $keycloak_new_admin_password = "admin",
        protected string $keycloak_old_admin_password = "admin",
        protected string $keycloak_db_username = "admin",
        protected string $keycloak_db_password = "admin",
        protected string $update_token = "",
        protected string $git_private_ssh_key_path = "",
        protected string $git_public_ssh_key_path = "",
    ) {}

    public function getHost() : string
    {
        return $this->host;
    }

    public function withHost(string $host) : Config
    {
        $clone = clone $this;
        $clone->host = $host;
        return $clone;
    }

    public function getAllowedHosts() : array
    {
        return $this->allowed_hosts;
    }

    public function withAllowedHosts(array $allowed_hosts) : Config
    {
        $clone = clone $this;
        $clone->allowed_hosts = $allowed_hosts;
        return $clone;
    }

    public function getHttpsProxy() : bool
    {
        return $this->https_proxy;
    }

    public function withHttpsProxy(bool $https_proxy) : Config
    {
        $clone = clone $this;
        $clone->https_proxy = $https_proxy;
        return $clone;
    }

    public function getMailPassword() : string
    {
        return $this->mail_password;
    }

    public function withMailPassword(string $mail_password) : Config
    {
        $clone = clone $this;
        $clone->mail_password = $mail_password;
        return $clone;
    }

    public function isKeycloakEnabled() : bool
    {
        return $this->keycloak_enabled;
    }

    public function withEnableKeycloak(bool $keycloak_enabled) : Config
    {
        $clone = clone $this;
        $clone->keycloak_enabled = $keycloak_enabled;
        return $clone;
    }

    public function getKeycloakHostname() : string
    {
        return $this->keycloak_hostname;
    }

    public function withKeycloakHostname(string $keycloak_hostname) : Config
    {
        $clone = clone $this;
        $clone->keycloak_hostname = $keycloak_hostname;
        return $clone;
    }

    public function getKeycloakNewAdminPassword() : string
    {
        return $this->keycloak_new_admin_password;
    }

    public function withKeycloakNewAdminPassword(string $keycloak_new_admin_password) : Config
    {
        $clone = clone $this;
        $clone->keycloak_new_admin_password = $keycloak_new_admin_password;
        return $clone;
    }

    public function getKeycloakOldAdminPassword() : string
    {
        return $this->keycloak_old_admin_password;
    }

    public function withKeycloakOldAdminPassword(string $keycloak_old_admin_password) : Config
    {
        $clone = clone $this;
        $clone->keycloak_old_admin_password = $keycloak_old_admin_password;
        return $clone;
    }

    public function getKeycloakDbUsername() : string
    {
        return $this->keycloak_db_username;
    }

    public function withKeycloakDbUsername(string $keycloak_db_username) : Config
    {
        $clone = clone $this;
        $clone->keycloak_db_username = $keycloak_db_username;
        return $clone;
    }

    public function getKeycloakDbPassword() : string
    {
        return $this->keycloak_db_password;
    }

    public function withKeycloakDbPassword(string $keycloak_db_password) : Config
    {
        $clone = clone $this;
        $clone->keycloak_db_password = $keycloak_db_password;
        return $clone;
    }

    public function getUpdateToken() : string
    {
        return $this->update_token;
    }

    public function withUpdateToken(string $update_token) : Config
    {
        $clone = clone $this;
        $clone->update_token = $update_token;
        return $clone;
    }

    public function getGitPrivateSSHKeyPath() : string
    {
        return $this->git_private_ssh_key_path;
    }

    public function withGitPrivateSSHKeyPath(string $git_private_ssh_key_path) : Config
    {
        $clone = clone $this;
        $clone->git_private_ssh_key_path = $git_private_ssh_key_path;
        return $clone;
    }

    public function getGitPublicSSHKeyPath() : string
    {
        return $this->git_public_ssh_key_path;
    }

    public function withGitPublicSSHKeyPath(string $git_public_ssh_key_path) : Config
    {
        $clone = clone $this;
        $clone->git_public_ssh_key_path = $git_public_ssh_key_path;
        return $clone;
    }

    public function __toString() : string
    {
        $allowed_hosts = implode(",", $this->allowed_hosts);
        $https_proxy = var_export($this->https_proxy, true);
        $keycloak_enabled = var_export($this->keycloak_enabled, true);

        return <<<DOC
host=$this->host
allowed_hosts=$allowed_hosts
https_proxy=$https_proxy
mail_password=$this->mail_password
keycloak_enabled=$keycloak_enabled
keycloak_hostname=$this->keycloak_hostname
keycloak_new_admin_password=$this->keycloak_new_admin_password
keycloak_old_admin_password=$this->keycloak_old_admin_password
keycloak_db_username=$this->keycloak_db_username
keycloak_db_password=$this->keycloak_db_password
update_token=$this->update_token
git_private_ssh_key_path=$this->git_private_ssh_key_path
git_public_ssh_key_path=$this->git_public_ssh_key_path
DOC;
    }
}