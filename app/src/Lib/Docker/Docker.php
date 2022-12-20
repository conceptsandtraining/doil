<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Docker;

interface Docker
{
    public function startContainerByDockerCompose(string $path) : void;
    public function stopContainerByDockerCompose(string $path) : void;
    public function ps() : array;
    public function getRunningInstanceNames() : array;
    public function loginIntoContainer(string $path, string $name) : void;
    public function isInstanceUp(string $path) : bool;
    public function executeCommand(string $path, string $name, ...$command) : void;
    public function executeBashCommandInsideContainer(string $name, ?string $working_dir, string ...$command) : void;
    public function executeQuietCommand(string $path, string $name, ...$command) : void;
    public function removeVolume(string $name) : void;
    public function getImageIdsByName(string $name) : array;
    public function removeImage(string $id) : void;

    /**
     * @return string[]
     */
    public function getSaltAcceptedKeys() : array;
    public function getShadowHashForInstance(string $name, string $password) : string;
    public function applyState(string $name, string $state) : string;
    public function commit(string $instance_name, ?string $image_name = null) : void;
    public function copy(string $instance_name, string $from, string $to) : void;
    public function listContainerDirectory(string $container_name, string $path) : array;
    public function pull(string $name) : void;
    public function build(string $path, string $name) : void;
    public function runContainer(string $name) : void;
    public function stop(string $name) : void;
    public function removeContainer(string $name) : void;
    public function executeDockerCommand(string $name, string $cmd) : void;
    public function setGrain(string $name, string $key, string $value) : void;
    public function deleteInstances(array $instances) : void;
    public function pruneNetworks() : void;
}