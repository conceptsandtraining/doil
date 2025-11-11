<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\System;

use CaT\Doil\Lib\Git\Git;
use Psr\Log\LoggerInterface;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Setup\Server\Salt;
use CaT\Doil\Setup\Server\Mail;
use CaT\Doil\Lib\Config\Config;
use CaT\Doil\Setup\Server\Proxy;
use CaT\Doil\Setup\CopyFiles\Copy;
use CaT\Doil\Setup\Server\Keycloak;
use CaT\Doil\Lib\Config\ConfigReader;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\Config\ConfigChecker;
use CaT\Doil\Lib\Logger\LoggerFactory;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Setup\Server\StartServers;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Filesystem\Exception\IOException;
use Symfony\Component\Console\Output\ConsoleOutputInterface;

class Update
{
    protected const DOIL_TARGET_DIR = "/tmp/doil";
    protected const GLOBAL_SAFE_DIRECTORY = "/usr/local/share/doil/repositories/*";
    protected const COMPOSER_LOCK = "/usr/local/lib/doil/app/composer.lock";
    protected const BUILD_FILE_NAME = "build_php_image.sh";
    protected const UPDATE_SCRIPT = "shell_update_steps.sh";

    protected int $user_id;
    protected string $home_dir;

    public function __construct(
        protected LoggerFactory $loggerFactory,
        protected ConsoleOutputInterface $output,
        protected InputInterface $input,
        protected Writer $writer,
        protected Git $git,
        protected Filesystem $filesystem,
        protected ConfigReader $configReader,
        protected ConfigChecker $config_checker,
        protected Copy $copy,
        protected Docker $docker,
        protected Posix $posix,
        protected Salt $salt,
        protected Proxy $proxy,
        protected Mail $mail,
        protected Keycloak $keycloak,
        protected StartServers $start_servers
    ) {
        $this->user_id = $this->posix->getUserId();
        $this->home_dir = $this->posix->getHomeDirectory($this->user_id);
    }

    public function run(string $repo, array $tags): void
    {
        $logger = $this->loggerFactory->getDoilLogger("UPDATE");

        $this->git->clone($repo, self::DOIL_TARGET_DIR);

        $update_conf = $this->filesystem->parseIniFile(self::DOIL_TARGET_DIR . "/Update/update.conf");
        $full_update = $update_conf["full_update"];
        $php_container_update = $update_conf["php_container_update"];

        try {
            $config = $this->configReader->getConfig();
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'sudo doil system:update' again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }

        $this->writer->beginBlock($this->output, "Checking doil config file");
        try {
            $this->config_checker->check($config);
        } catch (\InvalidArgumentException $e) {
            $this->writer->error(
                $this->output,
                "Cannot read config file!\n\t" . $e->getMessage(),
                "If the problem is fixed, run 'sudo doil system:update' again."
            );
            return;
        }
        $this->writer->endBlock();

        if (!$this->filesystem->exists($this->home_dir . "/" . self::BUILD_FILE_NAME)) {
            foreach ($tags as $tag) {
                $this->git->checkoutRemote(self::DOIL_TARGET_DIR, $tag);
                $this->copyDoil($logger, $config);
            }

            if (!$full_update) {
                $this->writer->beginBlock($this->output, "Executing additional shell script");
                $this->executeUpdateScript();
                $this->writer->endBlock();
                $this->output->writeln("Your doil installation is up to date.");
                return;
            }

            $this->removeDoilContainers();
            $this->git->setGlobalSafeDirectory(self::GLOBAL_SAFE_DIRECTORY);
            if ($this->filesystem->exists(self::COMPOSER_LOCK)) {
                $this->filesystem->remove(self::COMPOSER_LOCK);
            }

            if ($php_container_update) {
                $this->generatePHPImageScript();
                $this->output->writeln("\n\tDOIL needs your help!");
                $this->output->writeln("\n\tDoil tries to use as few dependencies as possible.\n\tTherefore, a PHP container is started with every Doil request.\n\tUpdates also run through this container. Since the running container\n\tcannot update itself, that's where you come in.");
                $this->output->writeln("\n\tDoil has created the script 'build_php_image.sh' in your home\n\tfolder. Please run this script as sudo and restart the update.\n\tIMPORTANT: Do not delete the script!\n\n\tThanks, you rock!");
                return;
            }

        }

        $this->filesystem->remove($this->home_dir . "/" . self::BUILD_FILE_NAME);

        $this->writer->beginBlock($this->output, "Starting doil system containers");
        $this->start_servers->run($config, $logger);
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Executing additional shell script");
        $this->executeUpdateScript();
        $this->writer->endBlock();

        $this->output->writeln("\nThanks for using doil, you rock!");
    }

    protected function copyDoil(LoggerInterface $logger, Config $config): void
    {
        $this->writer->beginBlock($this->output, "Copying doil files");
        try {
            $this->copy->copyDoil(self::DOIL_TARGET_DIR, $config);
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'sudo doil system:update' again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();
    }

    protected function removeDoilContainers(): void
    {
        $doil_related_containers = $this->docker->getDoilRelatedContainersNames();
        $doil_system_containers = array_filter(
            $doil_related_containers,
            fn ($container) => str_contains($container, "doil_")
        );

        foreach ($doil_related_containers as $doil_related_container) {
            $this->docker->kill($doil_related_container);
        }

        foreach ($doil_system_containers as $doil_system_container) {
            $this->docker->removeContainer($doil_system_container);
        }

        $this->docker->pruneImages();
    }

    protected function generatePHPImageScript(): void
    {
        $script = <<<EOF
#!/usr/bin/env bash

docker image rm doil_php:stable
docker buildx build -q -t doil_php:stable /usr/local/lib/doil/server/php
docker run --rm -ti -v /home:/home -v /usr/local/lib/doil:/usr/local/lib/doil -e PHP_INI_SCAN_DIR=/srv/php/mods-available -w /usr/local/lib/doil/app --user $(id -u):$(id -g) doil_php:stable /usr/local/bin/composer -q -n install
EOF;

        if (!$this->filesystem->hasWriteAccess($this->home_dir)) {
            throw new IOException("Unable to generate PHP image script!");
        }

        $this->filesystem->setContent($this->home_dir . "/" . self::BUILD_FILE_NAME, $script);

        $this->filesystem->chownRecursive($this->home_dir . "/" . self::BUILD_FILE_NAME, $this->user_id, $this->user_id);
        $this->filesystem->chmod($this->home_dir . "/" . self::BUILD_FILE_NAME, 0744);
    }

    protected function executeUpdateScript(): void
    {
        if (!$this->filesystem->exists(self::DOIL_TARGET_DIR . "/Update/" . self::UPDATE_SCRIPT)) {
            return;
        }

        $this->filesystem->chmod(self::DOIL_TARGET_DIR . "/Update/" . self::UPDATE_SCRIPT, 0744);

        shell_exec(self::DOIL_TARGET_DIR . "/Update/" . self::UPDATE_SCRIPT);
    }
}