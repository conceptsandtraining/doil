<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use PHPUnit\Framework\TestCase;
use Symfony\Component\Console\Tester\CommandTester;

class ListCommandTest extends TestCase
{
    public function test_execute() : void
    {
        $user_manager = $this->createMock(UserManager::class);
        $command = new ListCommand($user_manager);
        $tester = new CommandTester($command);

        $user_manager
            ->expects($this->once())
            ->method("getUsers")
            ->willReturn([
                new User("foo1"),
                new User("foo2")
            ])
        ;

        $execute_result = $tester->execute([]);
        $output = $tester->getDisplay(true);

        $result = "Currently registered users:\nfoo1\nfoo2\n";

        $this->assertEquals($result, $output);
        $this->assertEquals(0, $execute_result);
    }
}