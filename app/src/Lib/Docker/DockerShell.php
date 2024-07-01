<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Docker;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\SymfonyShell;
use CaT\Doil\Lib\Logger\LoggerFactory;

class DockerShell implements Docker
{
    use SymfonyShell;

    protected const SALT = "/usr/local/lib/doil/server/salt";
    protected const PROXY = "/usr/local/lib/doil/server/proxy";
    protected const MAIL = "/usr/local/lib/doil/server/mail";

    public function __construct(LoggerFactory $logger, Posix $posix)
    {
        $this->logger = $logger;
        $this->posix = $posix;
    }

    protected array $systems = [
        self::SALT,
        self::PROXY,
        self::MAIL
    ];

    public function startContainerByDockerCompose(string $path) : void
    {
        $this->startDoilSystemsIfNeeded();

        if ($path == self::PROXY) {
            $this->populateProxy();
        }

        if (in_array($path, $this->systems)) {
            return;
        }

        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "up",
            "-d",
            "--force-recreate"
        ];

        $logger = $this->logger->getDoilLogger(pathinfo($path, PATHINFO_FILENAME));
        $logger->info("Start instance");
        $this->run($cmd, $logger);

        // Sometimes this file will not be deleted automatically,
        // so we have to do it manually on start up.
        // If not, apache wouldn't start.
        $this->executeCommand(
            $path,
            basename($path),
            "/bin/bash",
            "-c",
            "rm -f /run/apache2/apache2.pid &>/dev/null"
        );

       $this->populateProxy();
    }

    public function stopContainerByDockerCompose(string $path) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "stop"
        ];

        $logger = $this->logger->getDoilLogger(pathinfo($path, PATHINFO_FILENAME));
        $logger->info("Stop instance");
        $this->run($cmd, $logger);

        if (!in_array($path, $this->systems)) {
            $this->cleanupProxy($path);
        }
    }

    public function ps() : array
    {
        $cmd = [
            "docker",
            "ps",
            "-a",
            "--format",
            "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.ID}}\t{{.Ports}}"
        ];
        $logger = $this->logger->getDoilLogger("DOCKER");
        return explode("\n", $this->run($cmd, $logger));
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
        $logger = $this->logger->getDoilLogger("DOCKER");
        return explode("\n", $this->run($cmd, $logger));
    }

    public function loginIntoContainer(string $path, string $name) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            $name,
            "bash"
        ];

        $logger = $this->logger->getDoilLogger($name);
        $user = $this->posix->getCurrentUserName();
        $logger->info("$user login into instance");

        $this->runTTY($cmd, $logger);
    }

    public function isInstanceUp(string $path) : bool
    {
        $cmd = [
           "docker",
           "compose",
           "-f",
           $path . "/docker-compose.yml",
           "top"
        ];

        $logger = $this->logger->getDoilLogger(pathinfo($path, PATHINFO_FILENAME));
        return $this->run($cmd, $logger) != "";
    }

    public function executeCommand(string $path, string $name, ...$command) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            $name
        ];

        $cmd = array_merge($cmd, $command);

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Execute command", $cmd);

        $this->runTTY($cmd, $logger);
    }

    public function executeNoTTYCommand(string $path, string $name, ...$command) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "exec",
            "-T",
            $name
        ];

        $cmd = array_merge($cmd, $command);

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Execute command", $cmd);

        $this->runNoTTYNoReturn($cmd, $logger);
    }

    public function executeBashCommandInsideContainer(string $name, ?string $working_dir, string ...$command) : void
    {
        $wd = "/";
        if (! is_null($working_dir)) {
            $wd = $working_dir;
        }

        $cmd = [
            "docker",
            "exec",
            "-it",
            "-w",
            $wd,
            $name,
            "bash",
            "-c"
        ];

        $cmd = array_merge($cmd, $command);

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Execute bash command", $cmd);

        $this->runTTY($cmd, $logger);
    }

    public function hasVolume(string $name) : bool
    {
        $cmd = [
            "docker",
            "volume",
            "ls",
            "-f",
            "name=$name",
            "--format",
            "{{.Name}}"
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Check if volume '$name' exists");

        $result = $this->run($cmd, $logger);
        return $result != "";
    }

    public function removeVolume(string $name) : void
    {
        $cmd = [
            "docker",
            "volume",
            "rm",
            $name
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Remove volume $name");

        $this->run($cmd, $logger);
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

        $logger = $this->logger->getDoilLogger("DOCKER");
        return explode("\n", $this->run($cmd, $logger));
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

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Remove image $id");

        $this->run($cmd, $logger);
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

        $logger = $this->logger->getSaltLogger("SALT");
        $keys = json_decode($this->run($cmd, $logger), true)["minions"];
        $logger->info($keys);
        return $keys;
    }

    public function getShadowHashForInstance(string $name, string $password) : string
    {
        $cmd = [
            "docker",
            "exec",
            "-i",
            "doil_saltmain",
            "bash",
            "-c",
            "salt \"$name\" shadow.gen_password \"$password\" --out txt"
        ];

        $logger = $this->logger->getSaltLogger("SALT");
        $result = explode(' ', $this->run($cmd, $logger));

        return trim($result[1]);
    }

    public function applyState(string $name, string $state) : void
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

        $logger = $this->logger->getSaltLogger($name);
        $logger->info("Apply salt state '$state'");
        $result = $this->run($cmd, $logger);
        $logger->info($result);
    }

    public function commit(string $instance_name, ?string $image_name = null) : void
    {
        if (is_null($image_name)) {
            $image_name = "doil/$instance_name";
        }

        $cmd = [
            "docker",
            "commit",
            $instance_name,
            "$image_name:stable"
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Commit $instance_name into $image_name:stable");
        $this->run($cmd, $logger);
    }

    public function copy(string $instance_name, string $from, string $to) : void
    {
        $cmd = [
            "docker",
            "cp",
            $instance_name . ":" . $from,
            $to
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Copy from $instance_name:$from to $to");
        $this->run($cmd, $logger);
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

        $logger = $this->logger->getDoilLogger("DOCKER");
        return explode("\n", trim($this->run($cmd, $logger)));
    }

    public function pull(string $name, string $tag) : void
    {
        $cmd = [
            "docker",
            "pull",
            $name . ":" . $tag
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Pull image $name:$tag");
        $this->run($cmd, $logger);
    }

    public function build(string $path, string $name) : void
    {
        $cmd = [
            "docker",
            "buildx",
            "build",
            "-t",
            "doil/" . $name . ":stable",
            $path
        ];

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Building image doil/$name:stable");
        $this->run($cmd, $logger);
    }

    public function runContainer(string $name) : void
    {
        $cmd = [
            "docker",
            "run",
            "-d",
            "--name",
            $name,
            "doil/base_global:stable"
        ];

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Run from doil/$name:stable");
        $this->run($cmd, $logger);
    }

    public function stop(string $name) : void
    {
        $cmd = [
            "docker",
            "stop",
            $name
        ];

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Stop instance");
        $this->run($cmd, $logger);
    }

    public function removeContainer(string $name) : void
    {
        $cmd = [
            "docker",
            "rm",
            "-f",
            $name
        ];

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Remove instance");
        $this->run($cmd, $logger);
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

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Execute docker command", $cmd);
        $this->run($cmd, $logger);
    }

    public function executeDockerCommandWithReturn(string $name, string $cmd) : string
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

        $logger = $this->logger->getDoilLogger($name);
        $logger->info("Execute docker command", $cmd);
        return $this->run($cmd, $logger);
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
            "salt \"$name\" grains.setval \"$key\" \"$value\""
        ];

        $logger = $this->logger->getSaltLogger($name);
        $logger->info("Set grain key '$key' with value '***' for instance '$name'");
        $this->runTTY($cmd, $logger);
    }

    public function refreshGrains(string $name) : void
    {
        $cmd = [
            "docker",
            "exec",
            "-d",
            "doil_saltmain",
            "bash",
            "-c",
            "salt \"$name\" saltutil.refresh_grains"
        ];

        $logger = $this->logger->getSaltLogger($name);
        $logger->info("Refresh grains for '$name'");
        $this->runTTY($cmd, $logger);
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

        $logger = $this->logger->getDoilLogger("DOCKER");
        $logger->info("Prune network");
        $this->run($cmd, $logger);
    }

    protected function getImageNameByInstance(string $instance) : string
    {
        $cmd = [
            "docker",
            "inspect",
            $instance,
            "--format={{.Config.Image}}"
        ];

        $logger = $this->logger->getDoilLogger("DOCKER");
        return $this->run($cmd, $logger);
    }

    protected function kill(string $name) : void
    {
        $cmd = [
            "docker",
            "kill",
            $name
        ];

        $logger = $this->logger->getDoilLogger($name);
        $this->run($cmd, $logger);
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
            sleep(5);
            $this->executeDockerCommand(
                "doil_mail",
                "supervisorctl start startup"
            );
        }
    }

    protected function startContainerByDockerComposeWithForceRecreate(string $path) : void
    {
        $cmd = [
            "docker",
            "compose",
            "-f",
            $path . "/docker-compose.yml",
            "up",
            "-d",
            "--force-recreate"
        ];

        $logger = $this->logger->getDoilLogger(pathinfo($path, PATHINFO_FILENAME));
        $logger->info("Start instance");
        $this->run($cmd, $logger);
    }

    protected function populateProxy() : void
    {
        $this->executeDockerCommand(
            "doil_proxy",
            "rm -f /etc/nginx/conf.d/sites/*"
        );

        $running_instances = $this->getRunningInstanceNames();
        $running_instances = array_filter($running_instances, function ($instance) {
            if (strstr($instance, "_local") || strstr($instance, "_global")) {
                return true;
            }
            return false;
        });
        foreach ($running_instances as $instance) {
            $ip = $this->getSaltIpByName($instance);
            $parts = explode("_", $instance);
            $trailer = array_pop($parts);
            if ($trailer == "global") {
                $instance = preg_replace("/_global$/", "", $instance);
            } else {
                $instance = preg_replace("/_local$/", "", $instance);
            }
            $this->executeDockerCommand(
                "doil_proxy",
                "/root/add-configuration.sh $ip $instance"
            );
        }

        $this->executeDockerCommand(
            "doil_proxy",
            "/root/generate_index_html.sh"
        );
    }

    protected function getSaltIpByName(string $name) : string
    {
        return trim($this->executeDockerCommandWithReturn(
            $name,
            "ip a | grep \"172.20.*\" | cut -d / -f1 | cut -d \" \" -f6"
        ));
    }

    protected function cleanupProxy(string $path) : void
    {
        $name = basename($path);
        $this->executeDockerCommand(
            "doil_proxy",
            "rm -f /etc/nginx/conf.d/sites/$name.conf &&  /root/generate_index_html.sh"
        );
    }
}