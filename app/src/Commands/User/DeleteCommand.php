<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class DeleteCommand extends Command
{
    use CLIHelper;

    protected static $defaultName = "user:delete";
    protected static $defaultDescription = "<fg=red>!NEEDS SUDO PRIVILEGES!</> Deletes a user from the doil system";

    protected UserManager $user_manager;
    protected Posix $posix;
    protected Linux $linux;
    protected Writer $writer;

    public function __construct(UserManager $user_manager, Posix $posix, Linux $linux, Writer $writer)
    {
        parent::__construct();

        $this->user_manager = $user_manager;
        $this->posix = $posix;
        $this->linux = $linux;
        $this->writer = $writer;
    }

    public function configure() : void
    {
        $this->addArgument("name", InputArgument::REQUIRED, "Name of the user to delete");
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if ($this->posix->getUserId() !== 0) {
            $this->writer->error(
                $output,
                "Please execute this script as sudo user!"
            );
            return Command::FAILURE;
        }

        $name = $input->getArgument("name");

        $home_dir = $this->posix->getHomeDirectoryByUserName($name);

        if (is_null($home_dir)) {
            $this->writer->error(
                $output,
                "User $name is not a system user!",
                "Please ensure that the user $name is a system user."
            );
            return Command::FAILURE;
        }

        $user = $this->user_manager->createUser($name);

        if (! $this->user_manager->userExists($user)) {
            $this->writer->error(
                $output,
                "User $name does not exist!",
                "Use <fg=gray>doil user:list</> to see all user!"
            );
            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Delete user from doil");
        $this->user_manager->deleteUser($user);
        $this->user_manager->deleteFileInfrastructure($home_dir);
        $this->linux->removeUserFromGroup($user->getName(), "doil");
        $this->writer->endBlock();

        return Command::SUCCESS;
    }
}