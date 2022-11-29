<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Console\Exception\InvalidArgumentException;

class UpdateCommand extends Command
{
    protected static $defaultName = "repo:update";
    protected static $defaultDescription =
        "Updates one or all repositories so that it won't be fetched when an instances is created.";

    protected RepoManager $repo_manager;
    protected Writer $writer;

    public function __construct(RepoManager $repo_manager, Writer $writer)
    {
        parent::__construct();

        $this->repo_manager = $repo_manager;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this
            ->addArgument("name", InputArgument::OPTIONAL, "The name of the repository to be updated")
            ->addOption("all", "a", InputOption::VALUE_NONE, "if is set all repos will be updated")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the repository to be updated is global")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $name = $input->getArgument("name");
        $global = $input->getOption("global");
        $all = $input->getOption("all");

        if (is_null($name) && ! $all) {
            throw new InvalidArgumentException("Not enough arguments (missing: \"name\" or \"all\")");
        }

        if ($all) {
            $repos = $this->repo_manager->getLocalRepos();
            $type = "local";
            if ($global) {
                $repos = $this->repo_manager->getGlobalRepos();
                $type = "global";
            }

            if (count($repos) == 0) {
                $this->writer->error(
                    $output,
                    "No repos found!",
                    "Use <fg=gray>doil repo:ls --help</> for more information."
                );
                return Command::FAILURE;
            }

            $helper = $this->getHelper("question");
            $question = new ConfirmationQuestion("Please confirm that you want to update ALL $type repos [yN]: ", false);
            if (!$helper->ask($input, $output, $question)) {
                $output->writeln("Abort by user!");
                return Command::FAILURE;
            }

            foreach ($repos as $repo) {
                $this->updateRepo($output, $repo->getName(), $repo->isGlobal());
            }
            return Command::SUCCESS;
        }

        return $this->updateRepo($output, $name, $global);
    }

    protected function updateRepo(OutputInterface $output, string $name, bool $global) : int
    {
        $check = $this->checkName();
        $check($name);

        $repo = $this->repo_manager->getEmptyRepo();
        $repo = $repo
            ->withName($name)
            ->withIsGlobal($global)
        ;

        if (! $this->repo_manager->repoExists($repo)) {
            $this->writer->error(
                $output,
                "Repository $name does not exists!",
                "Use <fg=gray>doil repo:list</> to see current installed repos."
            );
            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Update repo $name. This will take a while. Please be patient");
        $this->repo_manager->updateRepo($repo);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }

    protected function checkName() : Closure
    {
        return function(string $name) {
            if ("" == $name) {
                throw new RuntimeException("Name of the repo cannot be empty!");
            }
            if (! preg_match("/^[a-zA-Z0-9_]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only letters, numbers and underscores are allowed!");
            }

            return $name;
        };
    }
}