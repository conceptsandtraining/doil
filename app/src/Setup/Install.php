<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Setup;

use CaT\Doil\Setup\IP\IP;

use CaT\Doil\Setup\CopyFiles\Copy;
use CaT\Doil\Lib\Config\ConfigReader;
use CaT\Doil\Lib\Logger\LoggerFactory;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\Config\ConfigChecker;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Setup\Server\StartServers;
use CaT\Doil\Setup\FileStructure\BaseFiles;
use CaT\Doil\Setup\Filestructure\BaseDirectories;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Helper\QuestionHelper;
use Symfony\Component\Filesystem\Exception\IOException;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Process\Exception\ProcessFailedException;

class Install
{
    public function __construct(
        protected LoggerFactory $logger_factory,
        protected QuestionHelper $question_helper,
        protected ConsoleOutputInterface $output,
        protected InputInterface $input,
        protected Writer $writer,
        protected BaseDirectories $base_directories,
        protected BaseFiles $base_files,
        protected Copy $copy,
        protected IP $ip,
        protected ConfigReader $config_reader,
        protected ConfigChecker $config_checker,
        protected Filesystem $filesystem,
        protected StartServers $start_servers,
        protected string $script_dir
    ) {}

    public function run() : void
    {
        $this->writer->beginBlock($this->output, "Preparing the doil config file");
        try {
            $config = $this->config_reader->getConfig();
        } catch (IOException $e) {
            if (!$this->config_reader->writeToFile()) {
                $this->writer->error(
                    $this->output,
                    "Can't write config file!",
                    "Please run 'setup/uninstall' before running setup again."
                );
            }

            $question = new ConfirmationQuestion(
                "\n\tdoil adds a config at /etc/doil/doil.conf.\n\tPlease adjust this file to your needs.\n\tAt least you have to add the paths for your ssh keys.\n\tOtherwise the setup won't continue.\n\tContinue? [Yn]: ",
                true
            );

            if (!$this->question_helper->ask($this->input, $this->output, $question)) {
                $this->writer->error(
                    $this->output,
                    "Aborted by user!",
                    "Please run 'setup/uninstall' before running setup again."
                );
                return;
            }

            $config = $this->config_reader->getConfig();
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Checking doil config file");
        try {
            $this->config_checker->check($config);
        } catch (\InvalidArgumentException $e) {
            $this->writer->error(
                $this->output,
                "Cannot read config file!\n\t" . $e->getMessage(),
                "Please run 'setup/uninstall' before running setup again."
            );
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Creating doil base directories");
        try {
            $this->base_directories->createBaseDirs();
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Setting up setup logger");
        try {
            $logger = $this->logger_factory->getSetupLogger("SETUP");
        } catch (\InvalidArgumentException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            return;
        }
        $this->writer->endBlock();


        $this->writer->beginBlock($this->output, "Setting ownership for doil base directories");
        try {
            $this->base_directories->setOwnerGroupForBaseDirs();
            $logger->info("Setting ownership for doil base directories");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Setting file permissions for doil base directories");
        try {
            $this->base_directories->setFilePermissionsForBaseDirs();
            $logger->info("Setting file permissions for doil base directories");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Creating doil base files");
        try {
            $this->base_files->touchFiles();
            $logger->info("Creating doil base files");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Creating doil default user");
        if ($this->base_files->setDefaultUser() === false) {
            $this->writer->error(
                $this->output,
                "Cannot create doil default user!",
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error("Cannot create doil default user!");
            return;
        }
        $logger->info("Creating doil default user");
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Creating doil default repository");
        if ($this->base_files->setDefaultRepository() === false) {
            $this->writer->error(
                $this->output,
                "Cannot create doil default repository!",
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error("Cannot create doil default repository!");
            return;
        }
        $logger->info("Creating doil default repository");
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Setting file permissions for doil base files");
        try {
            $this->base_files->setFilePermissionsForBaseFiles();
            $logger->info("Setting file permissions for doil base files");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Setting file owner for doil base files");
        try {
            $this->base_files->setFileOwner();
            $logger->info("Setting file owner for doil base files");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Copying doil files");
        try {
            $this->copy->copyDoil($this->script_dir . "/..", $config);
            $logger->info("Copying doil files");
        } catch (IOException $e) {
            $this->writer->error(
                $this->output,
                $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
            return;
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Setting doil ip to hosts");
        if ($this->ip->setIPToHosts($config) === false) {
            $this->writer->error(
                $this->output,
                "Cannot set doil ip to hosts!",
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error("Cannot set doil ip to hosts!");
            return;
        }
        $logger->info("Setting doil ip to hosts");
        $this->writer->endBlock();

        $this->writer->beginBlock($this->output, "Starting doil system containers");
        try {
            $this->start_servers->run($config, $logger);
            $logger->info("Starting doil system containers");
        } catch (ProcessFailedException $e) {
            $this->writer->error(
                $this->output,
                "Starting doil system containers failed!\n" . $e->getMessage(),
                "If the problem is fixed, run 'setup/uninstall' before running setup again."
            );
            $logger->error($e->getTraceAsString());
        }
        $this->writer->endBlock();
    }
}

