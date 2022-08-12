<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

class Repo
{
    protected string $name;
    protected string $url;
    protected bool $global;

    public function __construct(string $name = "", string $url = "", bool $global = false)
    {
        $this->name = $name;
        $this->url = $url;
        $this->global = $global;
    }

    public function getName() : string
    {
        return $this->name;
    }

    public function withName(string $name) : Repo
    {
        $clone = clone $this;
        $clone->name = $name;
        return $clone;
    }

    public function getUrl() : string
    {
        return $this->url;
    }

    public function withUrl(string $url) : Repo
    {
        $clone = clone $this;
        $clone->url = $url;
        return $clone;
    }

    public function isGlobal() : bool
    {
        return $this->global;
    }

    public function withIsGlobal(bool $global) : Repo
    {
        $clone = clone $this;
        $clone->global = $global;
        return $clone;
    }
}