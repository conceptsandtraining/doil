<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib;

use PHPUnit\Framework\TestCase;

class ProjectConfigTest extends TestCase
{
    public function test_create() : void
    {
        $project_config = new ProjectConfig();

        $this->assertEmpty($project_config->getName());
        $this->assertEmpty($project_config->getRepositoryName());
        $this->assertEmpty($project_config->getRepositoryBranch());
        $this->assertEmpty($project_config->getRepositoryUrl());
        $this->assertEmpty($project_config->getPhpVersion());
    }

    public function test_create_with_params() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());
    }

    public function test_withName() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $new = $project_config->withName("test");

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());

        $this->assertEquals("test", $new->getName());
        $this->assertEquals("repo_name", $new->getRepositoryName());
        $this->assertEquals("repo_branch", $new->getRepositoryBranch());
        $this->assertEquals("repo_url", $new->getRepositoryUrl());
        $this->assertEquals("php_version", $new->getPhpVersion());
    }

    public function test_withRepositoryName() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $new = $project_config->withRepositoryName("test");

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());

        $this->assertEquals("name", $new->getName());
        $this->assertEquals("test", $new->getRepositoryName());
        $this->assertEquals("repo_branch", $new->getRepositoryBranch());
        $this->assertEquals("repo_url", $new->getRepositoryUrl());
        $this->assertEquals("php_version", $new->getPhpVersion());
    }

    public function test_withRepositoryBranch() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $new = $project_config->withRepositoryBranch("test");

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());

        $this->assertEquals("name", $new->getName());
        $this->assertEquals("repo_name", $new->getRepositoryName());
        $this->assertEquals("test", $new->getRepositoryBranch());
        $this->assertEquals("repo_url", $new->getRepositoryUrl());
        $this->assertEquals("php_version", $new->getPhpVersion());
    }

    public function test_withRepositoryUrl() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $new = $project_config->withRepositoryUrl("test");

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());

        $this->assertEquals("name", $new->getName());
        $this->assertEquals("repo_name", $new->getRepositoryName());
        $this->assertEquals("repo_branch", $new->getRepositoryBranch());
        $this->assertEquals( "test", $new->getRepositoryUrl());
        $this->assertEquals("php_version", $new->getPhpVersion());
    }

    public function test_withPhpVersion() : void
    {
        $project_config = new ProjectConfig(
            "name",
            "repo_name",
            "repo_branch",
            "repo_url",
            "php_version"
        );

        $new = $project_config->withPhpVersion("test");

        $this->assertEquals("name", $project_config->getName());
        $this->assertEquals("repo_name", $project_config->getRepositoryName());
        $this->assertEquals("repo_branch", $project_config->getRepositoryBranch());
        $this->assertEquals("repo_url", $project_config->getRepositoryUrl());
        $this->assertEquals("php_version", $project_config->getPhpVersion());

        $this->assertEquals("name", $new->getName());
        $this->assertEquals("repo_name", $new->getRepositoryName());
        $this->assertEquals("repo_branch", $new->getRepositoryBranch());
        $this->assertEquals("repo_url", $new->getRepositoryUrl());
        $this->assertEquals("test", $new->getPhpVersion());
    }
}