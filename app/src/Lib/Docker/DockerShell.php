<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Docker;

use CaT\Doil\Lib\SymfonyShell;

class DockerShell implements Docker
{
    use SymfonyShell;

    protected const SALT = "/usr/local/lib/doil/server/salt";
    protected const PROXY = "/usr/local/lib/doil/server/proxy";
    protected const MAIL = "/usr/local/lib/doil/server/mail";

    protected array $systems = [
        self::SALT,
        self::PROXY,
        self::MAIL
    ];

    public function startContainerByDockerCompose(string $path) : void
    {
        $this->startDoilSystemsIfNeeded();

        if (in_array($path, $this->systems)) {
            return;
        }

        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "up",
            "-d"
        ];

        $this->run($cmd);

        // Sometimes this file will not be deleted automatically,
        // so we have to do it manually on start up.
        // If not, apache wouldn't start.
        $this->executeQuietCommand(
            $path,
            basename($path),
            "/bin/bash",
            "-c",
            "rm -f /run/apache2/apache2.pid"
        );

        $this->cleanupMasterKey($path);
    }

    public function stopContainerByDockerCompose(string $path) : void
    {
        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "stop"
        ];

        $this->run($cmd);
    }

    public function ps() : array
    {
        $cmd = [
            "docker",
            "ps",
            "-a",
            "--format",
            "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Image}}\t{{.ID}}\t{{.Ports}}"
        ];
        return explode("\n", $this->run($cmd));
    }

    public function getRunningInstanceNames() : array
    {
        $cmd = [
            "docker",
            "ps",
            "--filter",
            "status=running",
            "--format",
            "{{.Names}}"
        ];
        return explode("\n", $this->run($cmd));
    }

    public function loginIntoContainer(string $path, string $name) : void
    {
        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            $name,
            "bash"
        ];

        $this->runTTY($cmd);
    }

    public function isInstanceUp(string $path) : bool
    {
        $cmd = [
           "docker-compose",
           "-f",
           $path . "/docker-compose.yml",
           "top"
        ];

        return $this->run($cmd) != "";
    }

    public function executeCommand(string $path, string $name, ...$command) : void
    {
        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            $name
        ];

        $cmd = array_merge($cmd, $command);

        $this->runTTY($cmd);
    }

    public function executeQuietCommand(string $path, string $name, ...$command) : void
    {
        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            $name
        ];

        $cmd = array_merge($cmd, $command);

        $this->runTTYQuiet($cmd);
    }

    public function removeVolume(string $name) : void
    {
        $cmd = [
            "docker",
            "volume",
            "rm",
            $name . "_persistent"
        ];

        $this->runTTYQuiet($cmd);
    }

    public function getImageIdsByName(string $name) : array
    {
        $cmd = [
            "docker",
            "images",
            $name,
            "-a",
            "-q"
        ];

        return explode("\n", $this->run($cmd));
    }

    public function removeImage(string $id) : void
    {
        $cmd = [
            "docker",
            "image",
            "rm",
            "-f",
            $id
        ];

        $this->run($cmd);
    }

    public function getSaltAcceptedKeys() : array
    {
        $cmd = [
            "docker",
            "exec",
            "-t",
            "doil_saltmain",
            "bash",
            "-c",
            "salt-key -L --out json"
        ];

        return json_decode($this->run($cmd), true)["minions"];
    }

    public function applyState(string $name, string $state) : string
    {
        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_saltmain",
            "bash",
            "-c",
            "salt \"$name\" state.highstate saltenv=$state"
        ];

        return $this->run($cmd);
    }

    public function commit(string $name) : void
    {
        $cmd = [
            "docker",
            "commit",
            $name,
            "doil/$name:stable"
        ];

        $this->run($cmd);
    }

    public function copy(string $instance_name, string $from, string $to) : void
    {
        $cmd = [
            "docker",
            "cp",
            $instance_name . ":" . $from,
            $to
        ];

        $this->run($cmd);
    }

    public function listContainerDirectory(string $container_name, string $path) : array
    {
        $cmd = [
            "docker",
            "exec",
            "-i",
            $container_name,
            "bash",
            "-c",
            "ls $path"
        ];

        return explode("\n", trim($this->run($cmd)));
    }

    public function pull(string $name) : void
    {
        $cmd = [
            "docker",
            "pull",
            $name . ":stable"
        ];

        $this->run($cmd);
    }

    public function build(string $path, string $name) : void
    {
        $cmd = [
            "docker",
            "build",
            "-t",
            "doil/" . $name . ":stable",
            $path
        ];

        $this->run($cmd);
    }

    public function runContainer(string $name) : void
    {
        $cmd = [
            "docker",
            "run",
            "-d",
            "--name",
            $name,
            "doil/" . $name . ":stable"
        ];

        $this->run($cmd);
    }

    public function stop(string $name) : void
    {
        $cmd = [
            "docker",
            "stop",
            $name
        ];

        $this->run($cmd);
    }

    public function removeContainer(string $name) : void
    {
        $cmd = [
            "docker",
            "rm",
            $name
        ];

        $this->run($cmd);
    }

    public function executeDockerCommand(string $name, string $cmd) : void
    {
        $cmd = [
            "docker",
            "exec",
            "-i",
            $name,
            "bash",
            "-c",
            $cmd
        ];

        $this->run($cmd);
    }

    public function setGrain(string $name, string $key, string $value) : void
    {
        $cmd = [
            "docker",
            "exec",
            "-d",
            "doil_saltmain",
            "bash",
            "-c",
            "salt \"$name\" grains.set \"$key\" \"$value\""
        ];

        $this->runTTY($cmd);
    }

    public function deleteInstances(array $instances) : void
    {
        foreach ($instances as $instance) {
            $image = $this->getImageNameByInstance($instance);
            $this->kill($instance);
            sleep(2);
            $this->removeContainer($instance);
            sleep(2);

            $this->removeImage($image);
        }
    }

    public function pruneNetworks() : void
    {
        $cmd = [
            "docker",
            "network",
            "prune",
            "-f"
        ];
        $this->runTTYQuiet($cmd);
    }

    protected function getImageNameByInstance(string $instance) : string
    {
        $cmd = [
            "docker",
            "inspect",
            $instance,
            "--format={{.Config.Image}}"
        ];

        return $this->run($cmd);
    }

    protected function kill(string $name) : void
    {
        $cmd = [
            "docker",
            "kill",
            $name
        ];

        $this->runTTYQuiet($cmd);
    }

    protected function startDoilSystemsIfNeeded() : void
    {
        if (! $this->isInstanceUp(self::SALT)) {
            $this->startContainerByDockerComposeWithForceRecreate(self::SALT);
        }
        if (! $this->isInstanceUp(self::PROXY)) {
            $this->startContainerByDockerComposeWithForceRecreate(self::PROXY);
        }
        if (! $this->isInstanceUp(self::MAIL)) {
            $this->startContainerByDockerComposeWithForceRecreate(self::MAIL);
        }
    }

    protected function startContainerByDockerComposeWithForceRecreate(string $path) : void
    {
        $cmd = [
            "docker-compose",
            "-f",
            $path . "/docker-compose.yml",
            "up",
            "-d",
            "--force-recreate"
        ];

        $this->run($cmd);
    }

    protected function cleanupMasterKey(string $path) : void
    {
        $name = basename($path);
        $this->executeQuietCommand(
            $path,
            $name,
            "/bin/bash",
            "-c",
            "rm -f /var/lib/salt/pki/minion/minion_master.pub"
        );
        $this->executeQuietCommand(
            $path,
            $name,
            "/bin/bash",
            "-c",
            "/etc/init.d/salt-minion restart"
        );
    }
}