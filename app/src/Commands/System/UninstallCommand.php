<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\System;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Commands\User\UserManager;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;

class UninstallCommand extends Command
{
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy";
    protected const SALT_PATH = "/usr/local/lib/doil/server/salt";
    protected const MAIL_PATH = "/usr/local/lib/doil/server/mail";

    protected static $defaultName = "system:uninstall";
    protected static $defaultDescription = "<fg=red>!NEEDS SUDO PRIVILEGES!</> Removes doil from the system";

    protected Docker $docker;
    protected Posix $posix;
    protected Filesystem $filesystem;
    protected Linux $linux;
    protected UserManager $user_manager;
    protected Writer $writer;

    public function __construct(
        Docker $docker,
        Posix $posix,
        Filesystem $filesystem,
        Linux $linux,
        UserManager $user_manager,
        Writer $writer
    ) {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->linux = $linux;
        $this->user_manager = $user_manager;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this
            ->addOption("prune", "p", InputOption::VALUE_NONE, "also delete all instances, doil users and doil config")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if ($this->posix->getUserId() !== 0) {
            $this->writer->error($output, "Please execute this script as sudo user!");
            return Command::FAILURE;
        }

        $helper = $this->getHelper("question");
        $question = new ConfirmationQuestion("Please confirm that you want to uninstall doil [yN]: ", false);

        if (!$helper->ask($input, $output, $question)) {
            $output->writeln("Abort by user!");
            return Command::FAILURE;
        }

        $prune = $input->getOption("prune");

        if ($prune) {
            $question = new ConfirmationQuestion("This will delete ALL doil users, doil instances and doil config. Do you want to proceed [yN]: ", false);

            if (!$helper->ask($input, $output, $question)) {
                $output->writeln("Abort by user!");
                return Command::FAILURE;
            }

            $this->writer->beginBlock($output, "Removing doil instances");
            $users = $this->user_manager->getUsers();
            foreach ($users as $user) {
                $local_instances_dir = "/home/" . $user->getName() . "/.doil/instances";
                if ($this->filesystem->exists($local_instances_dir)) {
                    $local_instances = $this->filesystem->getFilesInPath($local_instances_dir);
                    $local_instances = array_map(function ($i) use ($local_instances_dir) {
                        $instance = $local_instances_dir . "/" . $i;
                        $link = $this->filesystem->readLink($instance);
                        $this->filesystem->remove($instance);
                        $this->filesystem->remove($link);
                        return $i . "_local";
                    }, $local_instances);
                    $this->docker->deleteInstances($local_instances);
                }
            }

            $global_instances = [];
            $global_instances_dir = "/usr/local/share/doil/instances";
            if ($this->filesystem->exists($global_instances_dir)) {
                $global_instances = $this->filesystem->getFilesInPath($global_instances_dir);
                $global_instances = array_map(function($i) {
                    return $i . "_global";
                }, $global_instances);
            }

            $this->docker->deleteInstances($global_instances);
            $this->writer->endBlock();
        }

        $this->writer->beginBlock($output, "Removing proxy server");
        $this->docker->stopContainerByDockerCompose(self::PROXY_PATH);
        sleep(10);
        $this->docker->removeContainer("doil_proxy");
        foreach ($this->docker->getImageIdsByName("doil_proxy") as $id) {
            $this->docker->removeImage($id);
        }
        $this->docker->removeVolume("proxy_persistent");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Removing salt server ");
        $this->docker->stopContainerByDockerCompose(self::SALT_PATH);
        sleep(10);
        $this->docker->removeContainer("doil_saltmain");
        foreach ($this->docker->getImageIdsByName("doil_saltmain") as $id) {
            $this->docker->removeImage($id);
        }
        $this->docker->removeVolume("salt_persistent");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Removing mail server");
        $this->docker->stopContainerByDockerCompose(self::MAIL_PATH);
        sleep(10);
        $this->docker->removeContainer("doil_postfix");
        foreach ($this->docker->getImageIdsByName("doil_postfix") as $id) {
            $this->docker->removeImage($id);
        }
        $this->docker->removeVolume("mail_mail");
        $this->docker->removeVolume("mail_sieve");
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Removing doil");
        if ($prune) {
            $this->linux->deleteGroup("doil");
            $this->filesystem->remove(Filesystem::DOIL_PATH_MAIN_CONFIG);
            foreach ($users as $user) {
                $this->filesystem->remove("/home/" . $user->getName() . "/.doil");
            }
        }
        $this->filesystem->remove(Filesystem::DOIL_PATH_LIB);
        $this->filesystem->remove(Filesystem::DOIL_PATH_SHARE);
        $this->filesystem->remove(Filesystem::DOIL_PATH_BIN);

        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Removing doil networks");
        $this->docker->pruneNetworks();
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}