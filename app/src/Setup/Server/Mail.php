<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup\Server;

use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\SymfonyShell;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Mail
{
    use SymfonyShell;

    /**
     * @throws ProcessFailedException
     */
    public function start(LoggerInterface $logger, string $mail_password) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            "/usr/local/lib/doil/server/mail/docker-compose.yml",
            "up",
            "-d"
        ];

        $logger->info("Start instance doil_mail");
        $this->run($cmd, $logger);

        // Time for proxy registration on doil master
        sleep(20);

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.mail state.highstate saltenv=mailservices"
        ];

        $logger->info("Apply salt highstate on mail server");
        $this->run($cmd, $logger);

        if ($mail_password == "ilias") {
            return;
        }

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.mail shadow.gen_password \"{$mail_password}\" --out txt"
        ];
        $logger->info("Generate roundcube_password");
        $password = $this->run($cmd, $logger);
        $password = explode(" ", trim($password))[1];
        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.mail grains.setval 'roundcube_password' '{$password}'"
        ];
        $logger->info("Set roundcube_password grain");
        $this->run($cmd, $logger);

        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_salt",
            "bash",
            "-c",
            "salt doil.mail state.highstate saltenv=change-roundcube-password"
        ];
        $logger->info("Run change-roundcube-password state");
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
            "doil_mail",
            "doil_mail:stable"
        ];

        $logger->info("Commit instance doil_mail");
        $this->run($cmd, $logger);
    }
}