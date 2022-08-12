<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use PHPUnit\Framework\TestCase;

class UserTest extends TestCase
{
    public function test_create() : void
    {
        $repo = new User("user");

        $this->assertEquals("user", $repo->getName());
    }
}