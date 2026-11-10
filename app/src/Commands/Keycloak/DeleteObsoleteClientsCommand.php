<?php declare(strict_types=1);

/* Copyright (c) 2026 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Keycloak;

use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class DeleteObsoleteClientsCommand extends Command
{
    protected const KEYCLOAK_PATH = "/usr/local/lib/doil/server/keycloak";
    protected const DOIL_INI_PATH = "/etc/doil/doil.conf";
    protected const LOCAL_INSTANCES_PATH = ".doil/instances";
    protected const GLOBAL_INSTANCES_PATH = "/usr/local/share/doil/instances";

    protected static $defaultName = "keycloak:delete-obsolete-clients";
    protected static $defaultDescription = "<fg=red>!NEEDS SUDO PRIVILEGES!</> Deletes all obsolete keycloak clients";

    public function __construct(
        protected Docker $docker,
        protected Posix $posix,
        protected Filesystem $filesystem,
        protected Writer $writer
    ) {
        parent::__construct();
    }

    public function configure() : void
    {
        if (!$this->filesystem->exists(self::KEYCLOAK_PATH)) {
            $this->setHidden(true);
        }
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (!$this->posix->isSudo()) {
            $this->writer->error(
                $output,
                "Please execute this script as sudo user!"
            );
            return Command::FAILURE;
        }

        $doil_conf = $this->filesystem->parseIniFile(self::DOIL_INI_PATH);

        // get a list of all instance names
        $instance_names = [];
        $local_instances_dir = $this->posix->getHomeDirectory($this->posix->getUserId()) . "/" . self::LOCAL_INSTANCES_PATH;
        if (!$this->filesystem->exists($local_instances_dir)) {
            $this->writer->error(
                $output,
                "Directory '$local_instances_dir' doesn't exist. Please check your 'doil' installation."
            );
            return Command::FAILURE;
        }

        foreach ($this->filesystem->getFilesInPath($local_instances_dir) as $file) {
            $instance_names[] = $file;
        }

        $global_instances_dir = self::GLOBAL_INSTANCES_PATH;
        if (!$this->filesystem->exists($global_instances_dir)) {
            $this->writer->error(
                $output,
                "Directory '$global_instances_dir' doesn't exist. Please check your 'doil' installation."
            );
            return Command::FAILURE;
        }
        foreach ($this->filesystem->getFilesInPath($global_instances_dir) as $file) {
            $instance_names[] = $file;
        }

        // get a list of all clients in keycloak
        $keycloak_clients = $this->docker->executeDockerCommandWithReturn(
            "doil_keycloak",
            "/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password {$doil_conf["keycloak_new_admin_password"]} && /opt/keycloak/bin/kcadm.sh get clients | jq '.[] | select(.clientId|test(\".*/metadata.*\")).clientId' | cut -d '/' -f 4"
        );
        $keycloak_clients = explode("\n", trim($keycloak_clients));

        $diff = array_diff($keycloak_clients, $instance_names);

        // delete all obsolete keycloak clients
        foreach ($diff as $client) {
            $keycloak_client_id = $this->docker->executeDockerCommandWithReturn(
                "doil_keycloak",
                "/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password {$doil_conf["keycloak_new_admin_password"]} && /opt/keycloak/bin/kcadm.sh get clients | jq '.[] | select(.clientId|test(\".*/{$client}/.*\")).id' | tr -d '\"'"
            );
            $this->docker->executeBashCommandInsideContainer(
                "doil_keycloak",
                "/opt/keycloak/bin",
                "./kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password {$doil_conf["keycloak_new_admin_password"]} && ./kcadm.sh delete clients/{$keycloak_client_id}"
            );
        }

        return Command::SUCCESS;
    }
}