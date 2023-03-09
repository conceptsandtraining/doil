<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;

class AddCommand extends Command
{
    protected static $defaultName = "repo:add";
    protected static $defaultDescription =
        "Adds a repository to the doil configuration file to prepare the possibility "
        . "to use another repository within the create process of a new instance."
    ;

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
            ->addOption("name", "e", InputOption::VALUE_REQUIRED, "Sets the name of the repository")
            ->addOption("url", "u", InputOption::VALUE_REQUIRED, "Sets the url of the repository")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if the repository is added to the global repositories")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {


        $repo = $this->gatherRepoData($input, $output);

        $check = $this->checkName();
        $check($repo->getName());
        $check = $this->checkUrl();
        $check($repo->getUrl());

        if ($this->repo_manager->repoExists($repo)) {
            $this->writer->error(
                $output,
                "Repository {$repo->getName()} already exists!",
                "Use <fg=gray>doil repo:list</> to see current installed repos."
            );

            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Add repo {$repo->getName()} with url {$repo->getUrl()}");
        $this->repo_manager->addRepo($repo);
        $this->writer->endBlock();

        return Command::SUCCESS;
    }

    protected function gatherRepoData(InputInterface $input, OutputInterface $output) : Repo
    {
        $repo = $this->repo_manager->getEmptyRepo();
        $helper = $this->getHelper('question');

        // Name
        $name = $input->getOption("name");
        if (is_null($name)) {
            $question = new Question("Please enter a name for the repo to add: ");
            $question->setNormalizer(function ($v) {
                return $v ? trim($v) : '';
            });
            $question->setValidator($this->checkName());
            $name = $helper->ask($input, $output, $question);
        }
        $repo = $repo->withName($name);

        // URL
        $url = $input->getOption("url");
        if (is_null($url)) {
            $question = new Question("Please enter a url for the repo to add: ");
            $question->setNormalizer(function ($v) {
                return $v ? trim($v) : '';
            });
            $question->setValidator($this->checkUrl());
            $url = $helper->ask($input, $output, $question);
        }
        $repo = $repo->withUrl($url);

        // Global
        $global = $input->getOption("global");
        if (!$global && (is_null($name) || is_null($url))) {
            $question = new ConfirmationQuestion("Should the repo be global [yN]: ", false);

            if ($helper->ask($input, $output, $question)) {
                $global = true;
            }
        }
        $repo = $repo->withIsGlobal($global);

        return $repo;
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

    protected function checkUrl() : Closure
    {
        return function($answer) {
            if ("" == $answer) {
                throw new RuntimeException("Url of the repo cannot be empty!");
            }
            if (!preg_match("/((git|ssh|http(s)?)|(git@[\w.]+))(:(\/\/)?)([\w.@:\/\-~]+)(\.git)?/", $answer)) {
                throw new RuntimeException("Invalid github url.");
            }

            return $answer;
        };
    }
}