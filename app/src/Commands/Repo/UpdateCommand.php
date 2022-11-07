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

class UpdateCommand extends Command
{
    protected static $defaultName = "repo:update";
    protected static $defaultDescription =
        "Updates a local repository so that it won't be fetched when an instances is created.";

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
            ->addArgument("name", InputArgument::REQUIRED, "The name of the repository to be updated")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the repository to be updated is global")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $name = $input->getArgument("name");
        $global = $input->getOption("global");

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

        $this->writer->beginBlock($output, "Update repo. This will take a while. Please be patient");
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