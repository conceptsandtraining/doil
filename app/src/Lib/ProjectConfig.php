<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib;

class ProjectConfig
{
    protected string $name;
    protected string $repository_name;
    protected string $repository_branch;
    protected string $repository_url;
    protected string $php_version;

    public function __construct(
        string $name = "",
        string $repository_name = "",
        string $repository_branch = "",
        string $repository_url = "",
        string $php_version = ""
    ) {
        $this->name = $name;
        $this->repository_name = $repository_name;
        $this->repository_branch = $repository_branch;
        $this->repository_url = $repository_url;
        $this->php_version = $php_version;
    }

    public function getName() : string
    {
        return $this->name;
    }

    public function withName(string $name) : ProjectConfig
    {
        $clone = clone $this;
        $clone->name = $name;
        return $clone;
    }

    public function getRepositoryName() : string
    {
        return $this->repository_name;
    }

    public function withRepositoryName(string $repository_name) : ProjectConfig
    {
        $clone = clone $this;
        $clone->repository_name = $repository_name;
        return $clone;
    }

    public function getRepositoryBranch() : string
    {
        return $this->repository_branch;
    }

    public function withRepositoryBranch(string $repository_branch) : ProjectConfig
    {
        $clone = clone $this;
        $clone->repository_branch = $repository_branch;
        return $clone;
    }

    public function getRepositoryUrl() : string
    {
        return $this->repository_url;
    }

    public function withRepositoryUrl(string $repository_url) : ProjectConfig
    {
        $clone = clone $this;
        $clone->repository_url = $repository_url;
        return $clone;
    }

    public function getPhpVersion() : string
    {
        return $this->php_version;
    }

    public function withPhpVersion(string $php_version) : ProjectConfig
    {
        $clone = clone $this;
        $clone->php_version = $php_version;
        return $clone;
    }
}