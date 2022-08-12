<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use CaT\Doil\Lib\CLIHelper;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ListCommand extends Command
{
    use CLIHelper;

    protected static $defaultName = "repo:list";
    protected static $defaultDescription = "Lists all registered repositories.";

    protected RepoManager $repo_manager;

    public function __construct(RepoManager $repo_manager)
    {
        parent::__construct();

        $this->repo_manager = $repo_manager;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $local_repos = $this->repo_manager->getLocalRepos();
        $global_repos = $this->repo_manager->getGlobalRepos();

        $output->writeln("Currently registered local repositories:");
        foreach ($local_repos as $local_repo) {
            $output->writeln("\t" . $local_repo->getName() . " - " . $local_repo->getUrl());
        }

        $output->writeln("");

        $output->writeln("Currently registered global repositories:");
        foreach ($global_repos as $global_repo) {
            $output->writeln("\t" . $global_repo->getName() . " - " . $global_repo->getUrl());
        }

        return Command::SUCCESS;
    }
}