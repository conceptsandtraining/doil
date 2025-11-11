<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'user:list',
    description: "Lists all users of the doil system."
)]
class ListCommand extends Command
{
    public function __construct(protected UserManager $user_manager)
    {
        parent::__construct();
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