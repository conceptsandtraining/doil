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

class ApplyCommand extends Command
{
    protected const PATH_STATES = "/usr/local/share/doil/stack/states";

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
            ->addArgument("instance", InputArgument::REQUIRED, "name of the instance to apply state to")
            ->addArgument("state", InputArgument::OPTIONAL, "name of the state to apply")
            ->addOption("no_commit", "nc", InputOption::VALUE_NONE, "determines if an instance should not be committed")
            ->addOption("global", "g", InputOption::VALUE_NONE, "determines if an instance is global or not")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $instance = $input->getArgument("instance");
        $state = $input->getArgument("state");
        $no_commit = $input->getOption("no_commit");

        $suffix = "global";
        $path = "/usr/local/share/doil/instances/$instance";
        if (! $input->getOption("global")) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $suffix = "local";
            $path = "$home_dir/.doil/instances/$instance";
        }

        if (! $this->filesystem->exists($path)) {
            $this->writer->error(
                $output,
                "Instance not found!",
                "Use <fg=gray>doil instances:list</> to see current installed instances."
            );
            return Command::FAILURE;
        }

        if (is_null($state)) {
            $states = $this->filesystem->getFilesInPath(self::PATH_STATES);

            $helper = $this->getHelper("question");
            $question = new ChoiceQuestion(
                "Please select a state and enter its number:",
                $states,
                0
            );

            $question->setErrorMessage("State %s is invalid!");

            $state = $helper->ask($input, $output, $question);
        }

        $state_path = self::PATH_STATES . "/$state";

        if (! $this->filesystem->exists($state_path)) {
            $this->writer->error(
                $output,
                "The state $state does not exists!",
                "Use <fg=gray>doil instances:apply --help</> for mor information."
            );
            return Command::FAILURE;
        }

        if (!$this->docker->isInstanceUp($path)) {
            $this->docker->startContainerByDockerCompose($path);
        }

        $this->writer->beginBlock($output, "Waiting for salt key");
        $salt_keys = [];
        while (! in_array($instance . "." . $suffix, $salt_keys)) {
            sleep(5);
            $salt_keys = $this->docker->getSaltAcceptedKeys();
        }
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Apply state $state to $instance");
        $this->docker->applyState($instance . "." . $suffix, $state);
        $this->writer->endBlock();

        if (! $no_commit) {
            $this->docker->commit($instance . "_" . $suffix);
        }

        return Command::SUCCESS;
    }
}