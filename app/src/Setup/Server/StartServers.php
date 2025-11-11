<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\Config\Config;
use Symfony\Component\Process\Exception\ProcessFailedException;

class StartServers
{
    public function __construct(
        protected Salt $salt,
        protected Proxy $proxy,
        protected Mail $mail,
        protected Keycloak $keycloak,
    ) {}

    /**
     * @throws ProcessFailedException
     */
    public function run(Config $config, LoggerInterface $logger): void {
        $this->salt->start($logger);
        $this->salt->commit($logger);

        $this->proxy->start($logger, $config->getHost());
        $this->proxy->commit($logger);

        $this->mail->start($logger, $config->getMailPassword());
        $this->mail->commit($logger);

        if ($config->isKeycloakEnabled()) {
            $this->keycloak->start($logger, $config);
            $this->keycloak->commit($logger);
            $this->keycloak->distributeData($logger, $config);
        }
    }
}