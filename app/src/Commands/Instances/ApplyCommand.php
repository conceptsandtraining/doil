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
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class ApplyCommand extends Command
{
    protected const PATH_STATES = "/usr/local/share/doil/stack/states";

    protected static array $non_user_states = [
        "autoinstall",
        "base",
        "composer",
        "composer2",
        "composer54",
        "dev",
        "ilias",
        "mailservices",
        "proxyservices",
        "reactor",
        "change-roundcube-password",
        "nodejs",
        "proxy-enable-https"
    ];

    protected static $defaultName = "instances:apply";
    protected static $defaultDescription =
        "Apply state for the given instance. This is useful for re-applying singular state to your instance.";

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
            ->setAliases(["apply"])
            ->addArgument("instance", InputArgument::OPTIONAL, "name of the instance to apply state to")
            ->addArgument("state", InputArgument::OPTIONAL, "name of the state to apply")
            ->addOption("all", "a", InputOption::VALUE_NONE, "if is set apply state to all instances")
            ->addOption("no_commit", "nc", InputOption::VALUE_NONE, "determines if an instance should not be committed")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $state = $input->getArgument("state");
        $no_commit = $input->getOption("no_commit");
        $all = $input->getOption("all");

        if (is_null($instance) && ! $all) {
            throw new InvalidArgumentException("Not enough arguments (missing: \"instance\" or \"all\")");
        }

        if (in_array($state, self::$non_user_states)) {
            $this->writer->error(
                $output,
                "State '$state' is not allowed!",
                "This state is only for doil internal usage."
            );
            return Command::FAILURE;
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

        if (is_null($state)) {
            $states = $this->filesystem->getFilesInPath(self::PATH_STATES);

            $states = array_values(array_filter($states, function ($s) {
               if (in_array($s, self::$non_user_states)) {
                   return false;
               }
               return true;
            }));

            $selection = [];
            foreach ($states as $s) {
                $desc_path = self::PATH_STATES . "/" . $s . "/description.txt";
                if ($this->filesystem->exists($desc_path)) {
                    $line = $this->filesystem->getLineInFile($desc_path, "description");
                    $line = trim(substr($line, strpos($line, '=') + 1));
                    $state_len = strlen($s);
                    $line_len = strlen($line);
                    $selection[] = $s . str_pad(" - " . $line, 40 - $state_len + $line_len, " ", STR_PAD_LEFT);
                } else {
                    $selection[] = $s;
                }
            }

            $helper = $this->getHelper("question");
            $question = new ChoiceQuestion(
                "Please select a state and enter its number:",
                $selection,
                0
            );

            $question->setErrorMessage("State %s is invalid!");

            $state = $helper->ask($input, $output, $question);
            $pos = strpos($state, ' ');
            if ($pos) {
                $state = trim(substr($state, 0, $pos));
            }
        }

        $state_path = self::PATH_STATES . "/$state";

        if (! $this->filesystem->exists($state_path)) {
            $this->writer->error(
                $output,
                "The state $state does not exists!",
                "Use <fg=gray>doil instances:apply --help</> for more information."
            );
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
                $this->applyState(
                    $output,
                    $path . "/" . $i,
                    $i,
                    $state,
                    $suffix,
                    $no_commit
                );
            }
            return Command::SUCCESS;
        }

        return $this->applyState(
            $output,
            $path . "/" . $instance,
            $instance,
            $state,
            $suffix,
            $no_commit
        );
    }

    protected function applyState(
        OutputInterface $output,
        string $path,
        string $instance,
        string $state,
        string $suffix,
        bool $no_commit
    ) : int {
        if (! $this->docker->isInstanceUp($path)) {
            $this->docker->startContainerByDockerCompose($path);

            $this->writer->beginBlock($output, "Waiting for salt key");
            $salt_keys = [];
            while (! in_array($instance . "." . $suffix, $salt_keys)) {
                sleep(5);
                $salt_keys = $this->docker->getSaltAcceptedKeys();
            }
            $this->writer->endBlock();
        }

        $this->writer->beginBlock($output, "Apply state $state to $instance");
        $this->docker->applyState($instance . "." . $suffix, $state);
        $this->writer->endBlock();

        if (! $no_commit) {
            $this->docker->commit($instance . "_" . $suffix);
        }

        return Command::SUCCESS;
    }
}