<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class DeleteCommand extends Command
{
    protected const SALT_MAIN = "/usr/local/lib/doil/server/salt/";
    protected const POSTFIX = "/usr/local/lib/doil/server/mail/";
    protected const PROXY_SITES = "/usr/local/lib/doil/server/proxy/conf/nginx/sites/";
    protected const PROXY_PATH = "/usr/local/lib/doil/server/proxy/";

    protected static $defaultName = "instances:delete";
    protected static $defaultDescription =
        "This command deletes one or all instances. It will remove everything belonging " .
        "to the given instance including all its files, configuration and misc data."
    ;

    protected Docker $docker;
    protected Posix $posix;
    protected Filesystem $filesystem;
    protected Writer $writer;

    public function __construct(Docker $docker, Posix $posix, Filesystem $filesystem, Writer $writer)
    {
        parent::__construct();

        $this->docker = $docker;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this
            ->setAliases(["delete"])
            ->addArgument("instance", InputArgument::OPTIONAL, "name of the instance to delete")
            ->addOption("all", "a", InputOption::VALUE_NONE, "if is set all instances will be deleted")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $all = $input->getOption("all");

        if (is_null($instance) && ! $all) {
            throw new InvalidArgumentException("Not enough arguments (missing: \"instance\" or \"all\")");
        }

        $suffix = "global";
        $path = "/usr/local/share/doil/instances";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $suffix = "local";
            $path = "$home_dir/.doil/instances";
        }

        if (! $all && ! $this->filesystem->exists($path . "/" . $instance)) {
            $this->writer->error(
                $output,
                "Instance not found!",
                "Use <fg=gray>doil instances:list</> to see current installed instances."
            );
            return Command::FAILURE;
        }

        $helper = $this->getHelper("question");
        $question_msg = "Please confirm that you want to delete $instance [yN]: ";
        if ($all) {
            $question_msg = "Please confirm that you want to delete ALL instances [yN]: ";
        }
        $question = new ConfirmationQuestion($question_msg, false);

        if (!$helper->ask($input, $output, $question)) {
            $output->writeln("Abort by user!");
            return Command::FAILURE;
        }

        if ($all) {
            $instances = $this->filesystem->getFilesInPath($path);
            if (count($instances) == 0) {
                $this->writer->error(
                    $output,
                    "No instances found!",
                    "Use <fg=gray>doil instances:ls --help</> for more information."
                );
                return Command::FAILURE;
            }

            foreach ($instances as $i) {
                $this->deleteInstance(
                    $output,
                    $path . "/" . $i,
                    $i,
                    $suffix
                );
            }
            return Command::SUCCESS;
        }

        return $this->deleteInstance($output, $path . "/" . $instance, $instance, $suffix);
    }

    protected function deleteInstance(
        OutputInterface $output,
        string $path,
        string $instance,
        string $suffix
    ) : int {
        $this->writer->beginBlock($output, "Delete instance $instance");
        if (! $this->docker->isInstanceUp($path)) {
            $this->docker->startContainerByDockerCompose($path);
        }

        $user_id = $this->posix->getUserId();
        $group_id = $this->posix->getGroupId();
        $this->docker->executeCommand($path, $instance, "chown", "-R", "$user_id:$group_id", "/var/lib/mysql");
        $this->docker->executeCommand($path, $instance, "chown", "-R", "$user_id:$group_id", "/etc/mysql");
        $this->docker->executeCommand($path, $instance, "chown", "-R", "$user_id:$group_id", "/etc/php");

        $this->docker->stopContainerByDockerCompose($path);

        $instance_dir = $this->filesystem->readLink($path);
        $this->filesystem->remove($path);
        $this->filesystem->remove($instance_dir);

        $this->docker->removeContainer($instance . "_" . $suffix);

        $this->docker->executeCommand(self::SALT_MAIN, "doil_saltmain", "salt-key", "-d", "$instance.$suffix", "-y", "-q");

        $proxy_path = self::PROXY_SITES . $instance . ".conf";
        if ($this->filesystem->exists($proxy_path)) {
            $this->filesystem->remove($proxy_path);
        }

        $this->docker->executeQuietCommand(self::PROXY_PATH, "doil_proxy", "/etc/init.d/nginx", "reload");

        $this->docker->removeVolume($instance);

        foreach ($this->docker->getImageIdsByName("doil/" . $instance . "_" . $suffix) as $id) {
            $this->docker->removeImage($id);
        }

        $this->docker->executeQuietCommand(self::POSTFIX, "doil_postfix", "/root/delete-postbox-configuration.sh", $instance);

        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}