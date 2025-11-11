<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use CaT\Doil\Commands\Repo\RepoManager;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'user:add',
    description: "<fg=red>!NEEDS SUDO PRIVILEGES!</> Adds a user to the doil system."
)]
class AddCommand extends Command
{
    public function __construct(
        protected UserManager $user_manager,
        protected Posix $posix,
        protected Linux $linux,
        protected Filesystem $filesystem,
        protected Writer $writer,
        protected RepoManager $repo_manager
    ) {
        parent::__construct();
    }

    public function configure() : void
    {
        $this->addArgument("name", InputArgument::REQUIRED, "Name of the user to add");
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

        $name = $input->getArgument("name");

        $home_dir = $this->posix->getHomeDirectoryByUserName($name);

        if (is_null($home_dir) || ! $this->filesystem->exists($home_dir)) {
            $this->writer->error(
                $output,
                "User $name has no home directory.",
                "Please ensure that the user $name has a home directory."
            );
            return Command::FAILURE;
        }

        $user = $this->user_manager->createUser($name);

        if ($this->user_manager->userExists($user)) {
            $name = $user->getName();
            $this->writer->error(
                $output,
                "User $name already exist!",
                "Use <fg=gray>doil user:list</> to see all user!"
            );
            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Add user {$user->getName()} to doil");
        $this->user_manager->addUser($user);
        $this->user_manager->createFileInfrastructure($home_dir, $user->getName());
        $this->user_manager->ensureGlobalReposAreGitSafe($home_dir, $user);
        $this->linux->addUserToGroup($user->getName(), "doil");
        $this->writer->endBlock();

        $output->writeln("\nPlease ensure that {$user->getName()} is also member of the docker group!");
        $output->writeln("\t<fg=gray>sudo usermod -aG docker {$user->getName()}</>");

        return Command::SUCCESS;
    }
}