<?php

declare(strict_types=1);

/* Copyright (c) 2025 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\System;

use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\System\Update;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ConfirmationQuestion;

#[AsCommand(
    name: 'system:update',
    description: "<fg=red>!NEEDS SUDO PRIVILEGES!</> This command updates doil on your system."
)]
class UpdateCommand extends Command
{
    protected const DOIL_GIT_REPO = "https://github.com/conceptsandtraining/doil.git";

    public function __construct(
        protected Posix $posix,
        protected Filesystem $filesystem,
        protected Git $git,
        protected Update $update,
        protected Writer $writer
    ) {
        parent::__construct();
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $this->posix->isSudo()) {
            $this->writer->error(
                $output,
                "Please execute this script as sudo user!"
            );
            return Command::FAILURE;
        }

        $version = $this->filesystem->getLineInFile("/usr/local/lib/doil/app/src/App.php", "Doil Version");
        $version = explode(" ", $version)[5];

        $output->writeln("Current version: {$version}");

        $tags = $this->git->getTagsFromGithubUrl(self::DOIL_GIT_REPO);

        $tags = array_filter($tags, fn ($tag) => $tag > $version);

        if (count($tags) == 0) {
            $output->writeln("Nothing to do. Everything is up to date!");
            return Command::SUCCESS;
        }

        $output->writeln("Possible updates");
        foreach ($tags as $tag) {
            $output->writeln("\t$tag");
        }

        $question = new ConfirmationQuestion(
            "This update will update to the latest available version.\nDo you want to continue the update? [y/N] ",
            false
        );
        $helper = $this->getHelper('question');
        if (! $helper->ask($input, $output, $question)) {
            $this->writer->error(
                $output,
                "Aborted by user!",
                "Please run 'sudo doil system:update' again to continue update."
            );
            return Command::FAILURE;
        }

        $this->update->run(self::DOIL_GIT_REPO, $tags);

        return Command::SUCCESS;
    }
}