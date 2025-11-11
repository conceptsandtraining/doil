<?php declare(strict_types=1);

namespace CaT\Doil\Commands\Repo;

use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\Attributes\AllowMockObjectsWithoutExpectations;

#[AllowMockObjectsWithoutExpectations]
class RepoTest extends TestCase
{
    public function test_create() : void
    {
        $repo = new Repo();

        $this->assertEmpty($repo->getName());
        $this->assertEmpty($repo->getUrl());
        $this->assertFalse($repo->isGlobal());
    }

    public function test_create_with_values() : void
    {
        $repo = new Repo("name", "url", true);

        $this->assertEquals("name", $repo->getName());
        $this->assertEquals("url", $repo->getUrl());
        $this->assertTrue($repo->isGlobal());
    }

    public function test_withName() : void
    {
        $repo = new Repo("name", "url", true);
        $new_repo = $repo->withName("name1");

        $this->assertEquals("name", $repo->getName());
        $this->assertEquals("url", $repo->getUrl());
        $this->assertTrue($repo->isGlobal());

        $this->assertEquals("name1", $new_repo->getName());
        $this->assertEquals("url", $new_repo->getUrl());
        $this->assertTrue($new_repo->isGlobal());
    }

    public function test_withUrl() : void
    {
        $repo = new Repo("name", "url", true);
        $new_repo = $repo->withUrl("url1");

        $this->assertEquals("name", $repo->getName());
        $this->assertEquals("url", $repo->getUrl());
        $this->assertTrue($repo->isGlobal());

        $this->assertEquals("name", $new_repo->getName());
        $this->assertEquals("url1", $new_repo->getUrl());
        $this->assertTrue($new_repo->isGlobal());
    }

    public function test_withIsGlobal() : void
    {
        $repo = new Repo("name", "url", true);
        $new_repo = $repo->withIsGlobal(false);

        $this->assertEquals("name", $repo->getName());
        $this->assertEquals("url", $repo->getUrl());
        $this->assertTrue($repo->isGlobal());

        $this->assertEquals("name", $new_repo->getName());
        $this->assertEquals("url", $new_repo->getUrl());
        $this->assertFalse($new_repo->isGlobal());
    }
}