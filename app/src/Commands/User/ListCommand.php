<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ListCommand extends Command
{
    protected static $defaultName = "user:list";
    protected static $defaultDescription = "Lists all users of the doil system";

    protected UserManager $user_manager;

    public function __construct(UserManager $user_manager)
    {
        parent::__construct();

        $this->user_manager = $user_manager;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $users = $this->user_manager->getUsers();

        $output->writeln("Currently registered users:");
        foreach ($users as $user) {
            $output->writeln($user->getName());
        }

        return Command::SUCCESS;
    }
}