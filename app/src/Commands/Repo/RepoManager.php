<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Repo;

use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\CLIHelper;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\FileSystem\Filesystem;

class RepoManager
{
    use CLIHelper;

    protected const LOCAL_REPO_CONFIG_PATH = "/.doil/config/repositories.json";
    protected const GLOBAL_REPO_CONFIG_PATH = "/etc/doil/repositories.json";
    protected const LOCAL_REPO_PATH = "/.doil/repositories";
    protected const GLOBAL_REPO_PATH = "/usr/local/share/doil/repositories";

    protected Git $git;
    protected Posix $posix;
    protected Filesystem $filesystem;

    public function __construct(Git $git, Posix $posix, Filesystem $filesystem)
    {
        $this->git = $git;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
    }

    public function getEmptyRepo() : Repo
    {
        return new Repo();
    }

    public function repoExists(Repo $repo) : bool
    {
        $repos = $this->getLocalRepos();
        if ($repo->isGlobal()) {
            $repos = $this->getGlobalRepos();
        }

        $repos = array_filter($repos, function(Repo $r) use ($repo) {
            if ($repo->getName() == $r->getName()) {
                return true;
            }
            return false;
        });

        return (bool) count($repos);
    }

    public function addRepo(Repo $repo) : void
    {
        $repos = $this->getGlobalRepos();
        $json_path = self::GLOBAL_REPO_CONFIG_PATH;

        if (! $repo->isGlobal()) {
            $repos = $this->getLocalRepos();
            $json_path = $this->posix->getHomeDirectory($this->posix->getUserId()) . self::LOCAL_REPO_CONFIG_PATH;
        }

        $repos[] = $repo;

        $this->filesystem->saveToJsonFile($json_path, $repos);
    }

    public function deleteRepo(Repo $repo) : void
    {
        $json_path = self::GLOBAL_REPO_CONFIG_PATH;
        $repo_path = self::GLOBAL_REPO_PATH . "/" . $repo->getName();
        $repos = $this->getGlobalRepos();

        if (! $repo->isGlobal()) {
            $repos = $this->getLocalRepos();
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $json_path = $home_dir . self::LOCAL_REPO_CONFIG_PATH;
            $repo_path = $home_dir . self::LOCAL_REPO_PATH . "/" . $repo->getName();
        }

        foreach ($repos as $key => $r) {
            if ($r->getName() == $repo->getName()) {
                unset($repos[$key]);
            }
        }

        $this->filesystem->remove($repo_path);
        $this->filesystem->saveToJsonFile($json_path, $repos);
    }

    public function updateRepo(Repo $repo) : void
    {
        $path = self::GLOBAL_REPO_PATH;
        $repos = $this->getGlobalRepos();

        if (! $repo->isGlobal()) {
            $repos = $this->getLocalRepos();
            $path = $this->posix->getHomeDirectory($this->posix->getUserId()) . self::LOCAL_REPO_PATH;
        }

        if ($this->filesystem->exists($path . "/" . $repo->getName())) {
            $this->git->fetchBare($path . "/" . $repo->getName(), $repo->getUrl());
            return;
        }

        $repos = array_filter($repos, function(Repo $r) use ($repo) {
            if ($r->getName() == $repo->getName()) {
                return true;
            }
            return false;
        });

        $repo = array_shift($repos);

        $this->git->cloneBare($repo->getUrl(), $path . "/" . $repo->getName());
    }

    /**
     * @return Repo[]
     */
    public function getLocalRepos() : array
    {
        $path = $this->posix->getHomeDirectory($this->posix->getUserId()) . self::LOCAL_REPO_CONFIG_PATH;

        if (! $this->filesystem->exists($path)) {
            return [];
        }

        return $this->filesystem->readFromJsonFile($path);
    }

    /**
     * @return Repo[]
     */
    public function getGlobalRepos() : array
    {
        if (! $this->filesystem->exists(self::GLOBAL_REPO_CONFIG_PATH)) {
            return [];
        }

        return $this->filesystem->readFromJsonFile(self::GLOBAL_REPO_CONFIG_PATH);
    }

    public function getLocalRepo(string $name) : Repo
    {
        $repos = $this->getLocalRepos();
        $repos = array_filter($repos, function(Repo $r) use ($name) {
            if ($name == $r->getName()) {
                return true;
            }
            return false;
        });

        if (! count($repos)) {
            throw new RuntimeException("Repo $name not found in local repos.");
        }

        return array_shift($repos);
    }

    public function getGlobalRepo(string $name) : Repo
    {
        $repos = $this->getGlobalRepos();
        $repos = array_filter($repos, function(Repo $r) use ($name) {
            if ($name == $r->getName()) {
                return true;
            }
            return false;
        });

        if (! count($repos)) {
            throw new RuntimeException("Repo $name not found in global repos.");
        }

        return array_shift($repos);
    }
}