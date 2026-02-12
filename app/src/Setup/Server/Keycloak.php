<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Keycloak
{
    use SymfonyShell;

    public function __construct(
        protected Filesystem $filesystem,
    ) {}

    /**
     * @throws ProcessFailedException
     */
    public function start(LoggerInterface $logger, Config $config) : void
    {
        $replace_data = [
            "/usr/local/lib/doil/server/keycloak/conf/keycloak-startup.conf" => [
                "%TPL_SERVER_HOSTNAME%" => $config->getKeycloakHostname(),
                "%TPL_DB_USERNAME%" => $config->getKeycloakDbUsername(),
                "%TPL_DB_PASSWORD%" => $config->getKeycloakDbPassword()
            ],
            "/usr/local/lib/doil/server/keycloak/conf/init.sql" => [
                "%TPL_DB_USERNAME%" => $config->getKeycloakDbUsername(),
                "%TPL_DB_PASSWORD%" => $config->getKeycloakDbPassword()
            ],
            "/usr/local/share/doil/stack/states/keycloak/keycloak/init.sls" => [
                "%TPL_NEW_ADMIN_PASSWORD%" => $config->getKeycloakNewAdminPassword(),
                "%TPL_OLD_ADMIN_PASSWORD%" => $config->getKeycloakOldAdminPassword()
            ]
        ];

        $this->replace($replace_data);

        $cmd = [
            "docker",
            "compose",
            "-f",
            "/usr/local/lib/doil/server/keycloak/docker-compose.yml",
            "up",
            "-d"
        ];

        $logger->info("Start instance doil_keycloak");
        $this->run($cmd, $logger);

        // Time for proxy registration on doil master
        sleep(120);

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.keycloak state.highstate saltenv=keycloak"
        ];

        $logger->info("Apply salt highstate on keycloak server");
        $this->run($cmd, $logger);
    }

    /**
     * @throws ProcessFailedException
     */
    public function commit(LoggerInterface $logger) : void
    {
        $cmd = [
            "docker",
            "commit",
            "doil_keycloak",
            "doil_keycloak:stable"
        ];

        $logger->info("Commit instance doil_keycloak");
        $this->run($cmd, $logger);
    }

    /**
     * @throws ProcessFailedException
     */
    public function distributeData(LoggerInterface $logger, Config $config) : void
    {
        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt 'doil.keycloak' http.query http://localhost:8080/realms/master/protocol/saml/descriptor --out=raw | cut -d \"'\" -f6"
        ];

        $logger->info("Get idp meta data");
        $idp_metadata = $this->run($cmd, $logger);

        $replace_data = [
            "/usr/local/share/doil/stack/states/enable-saml/saml/init.sls" => [
                "%TPL_IDP_META%" => $idp_metadata,
                "%TPL_KEYCLOAK_HOSTNAME%" => $config->getKeycloakHostname(),
                "%TPL_ADMIN_PASSWORD%" => $config->getKeycloakNewAdminPassword()
            ],
            "/usr/local/share/doil/stack/states/disable-saml/saml/init.sls" => [
                "%TPL_KEYCLOAK_HOSTNAME%" => $config->getKeycloakHostname(),
                "%TPL_ADMIN_PASSWORD%" => $config->getKeycloakNewAdminPassword()
            ]
        ];

        $this->replace($replace_data);
    }

    protected function replace(array $replace_data) : void
    {
        foreach ($replace_data as $file => $replacements) {
            foreach ($replacements as $needle => $replacement) {
                $this->filesystem->replaceStringInFile($file, $needle, $replacement);
            }
        }
    }
}