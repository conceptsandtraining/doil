<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\User;

use CaT\Doil\Commands\Repo\Repo;
use CaT\Doil\Lib\FileSystem\Filesystem;

class UserManager
{
    protected const USER_CONFIG_PATH = "/etc/doil/user.json";
    protected const USER_PATH_LOCAL_CONFIG = "/.doil/config";
    protected const USER_PATH_LOCAL_REPOSITORIES = "/.doil/repositories";
    protected const USER_PATH_LOCAL_INSTANCES = "/.doil/instances";

    protected Filesystem $filesystem;

    public function __construct(Filesystem $filesystem)
    {
        $this->filesystem = $filesystem;
    }

    public function createUser(string $name) : User
    {
        return new User($name);
    }

    public function userExists(User $user) : bool
    {
        $users = $this->getUsers();

        $users = array_filter($users, function($u) use ($user) {
            return $u->getName() == $user->getName();
        });

        return (bool) count($users);
    }

    /**
     * @return User[]
     */
    public function getUsers() : array
    {
        if (! $this->filesystem->exists(self::USER_CONFIG_PATH)) {
            return [];
        }
        return $this->filesystem->readFromJsonFile(self::USER_CONFIG_PATH);
    }

    public function addUser(User $user) : void
    {
        $users = $this->getUsers();
        $users[] = $user;
        $this->saveUsers($users);
    }

    public function createFileInfrastructure(string $home_dir, $owner) : void
    {
        $this->filesystem->makeDirectoryRecursive($home_dir . self::USER_PATH_LOCAL_CONFIG);
        $this->filesystem->makeDirectoryRecursive($home_dir . self::USER_PATH_LOCAL_REPOSITORIES);
        $this->filesystem->makeDirectoryRecursive($home_dir . self::USER_PATH_LOCAL_INSTANCES);
        $this->filesystem->chownRecursive($home_dir . "/.doil", $owner, $owner);
    }

    public function deleteFileInfrastructure(string $path) : void
    {
        $this->filesystem->remove($path . "/.doil");
    }

    public function deleteUser(User $user) : void
    {
        $users = $this->getUsers();

        $users = array_filter($users, function(User $u) use ($user) {
            return $u->getName() != $user->getName();
        });

        $this->saveUsers($users);
    }

    /**
     * @param array<Repo>  $repos
     */
    public function ensureGlobalReposAreGitSafe(string $home_dir, User $user) : void
    {
        $this->filesystem->addToGitConfig($home_dir, "safe", "directory = /usr/local/share/doil/repositories/*");
        $this->filesystem->chownRecursive($home_dir . "/.gitconfig", $user->getName(), $user->getName());
    }

    /**
     * @param User[]
     */
    protected function saveUsers(array $users) : void
    {
        $this->filesystem->saveToJsonFile(self::USER_CONFIG_PATH, $users);
    }
}