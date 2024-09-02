<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Pack;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Commands\Repo\Repo;
use CaT\Doil\Lib\ILIAS\IliasInfo;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\ConfirmationQuestion;

class PackCreateCommand extends Command
{
    protected const DEBIAN_TAG = "11";
    protected const LOCAL_REPO_PATH = "/.doil/repositories";
    protected const GLOBAL_REPO_PATH = "/usr/local/share/doil/repositories";
    protected const LOCAL_INSTANCES_PATH = "/.doil/instances";
    protected const GLOBAL_INSTANCES_PATH = "/usr/local/share/doil/instances";
    protected const BASIC_FOLDERS = [
        "/conf",
        "/conf/salt",
        "/volumes/db",
        "/volumes/index",
        "/volumes/data",
        "/volumes/logs/error",
        "/volumes/logs/apache",
        "/volumes/etc/apache2",
        "/volumes/logs/xdebug",
        "/volumes/etc/php",
        "/volumes/etc/mysql",
    ];

    protected static $defaultName = "pack:create";
    protected static $defaultDescription =
        "This command creates an instance depending on the given parameters. If you do not specify any parameter you will be prompted with a wizard.";

    protected Docker $docker;
    protected RepoManager $repo_manager;
    protected Git $git;
    protected Posix $posix;
    protected Filesystem $filesystem;
    protected Linux $linux;
    protected ProjectConfig $project_config;
    protected Writer $writer;
    protected IliasInfo $ilias_info;

    public function __construct(
        Docker $docker,
        RepoManager $repo_manager,
        Git $git,
        Posix $posix,
        Filesystem $filesystem,
        Linux $linux,
        ProjectConfig $project_config,
        Writer $writer,
        IliasInfo $ilias_info
    ) {
        parent::__construct();

        $this->docker = $docker;
        $this->repo_manager = $repo_manager;
        $this->git = $git;
        $this->posix = $posix;
        $this->filesystem = $filesystem;
        $this->linux = $linux;
        $this->project_config = $project_config;
        $this->writer = $writer;
        $this->ilias_info = $ilias_info;
    }

    public function configure() : void
    {
        $this
            ->setAliases(["pack-create"])
            ->addOption("name", "e", InputOption::VALUE_OPTIONAL, "Sets the name of the instance")
            ->addOption("repo", "r", InputOption::VALUE_OPTIONAL, "Sets the repository to use")
            ->addOption("use-global-repo", "u", InputOption::VALUE_NONE, "Determines if the repo is global one or not")
            ->addOption("branch", "b", InputOption::VALUE_OPTIONAL, "Sets the branch to use")
            ->addOption("phpversion", "p", InputOption::VALUE_OPTIONAL, "Sets the php version to use")
            ->addOption("target", "t", InputOption::VALUE_OPTIONAL, "Sets the target destination for the instance. If the folder does not exist, it will be created. Will be ignored while creating global instances")
            ->addOption("xdebug", "x", InputOption::VALUE_NONE, "Determines if xdebug should be installed or not")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
            ->addOption("skip-readme", "s", InputOption::VALUE_NONE, "Doesn't create the README.md file")
            ->setHidden(true)
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        $options = $this->gatherOptionData($input, $output);

        $instance_path = $options["target"] . "/" . $options["name"];
        $suffix = $options["global"] ? "global" : "local";
        $instance_name = $options["name"] . "_" . $suffix;
        $instance_salt_name = $options["name"] . "." . $suffix;
        $user_name = $this->posix->getCurrentUserName();
        $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());

        if ($this->filesystem->exists($instance_path)) {
            $this->writer->error(
                $output,
                $options["name"] . " already exists!",
                "See <fg=gray>doil instances:create --help</> for more information."
            );
            return Command::FAILURE;
        }

        if (! $this->filesystem->exists($home_dir . "/.ssh")) {
            $this->writer->error(
                $output,
                "Folder $home_dir/.ssh not found."
            );
            return Command::FAILURE;
        }

        $this->writer->beginBlock($output, "Creating instance " . $options['name']);

        if (isset($options["repo_path"]) && ! $this->filesystem->exists($options["repo_path"])) {
            $this->writer->beginBlock($output, "Clone repo. This will take a while. Please be patient");
            $this->git->cloneBare($options["repo_url"], $options["repo_path"]);
            $this->writer->endBlock();
        }

        if (isset($options["repo_path"])) {
            $branches = $this->getBranches($output, $options["repo_path"], $options["repo_url"]);
            if (!in_array($options["branch"], $branches)) {
                throw new RuntimeException($options["branch"] . " is not a branch from " . $options["repo_url"]);
            }
        }

        // install base image if not exists
        if ($this->docker->getImageIdsByName("doil/base_global")[0] == "") {
            $this->writer->beginBlock($output, "Update debian image");
            $this->docker->pull("debian", self::DEBIAN_TAG);
            $this->writer->endBlock();

            $this->writer->beginBlock($output, "Install base image. This will take a while. Please be patient");
            $this->docker->build("/usr/local/share/doil/templates/base", "base_global");
            $this->writer->endBlock();
        }

        // create basic folders
        $this->writer->beginBlock($output, "Create basic folders");
        foreach (self::BASIC_FOLDERS as $folder) {
            $this->filesystem->makeDirectoryRecursive($instance_path . $folder);
        }
        $this->writer->endBlock();

        // create symlink
        $this->writer->beginBlock($output, "Link instance");
        if ($options["global"]) {
            $this->filesystem->symlink($instance_path, self::GLOBAL_INSTANCES_PATH . "/" . $options["name"]);
        } else {
            $this->filesystem->symlink($instance_path, $home_dir . self::LOCAL_INSTANCES_PATH . "/" . $options["name"]);
        }
        $this->writer->endBlock();

        // set folder permissions
        $this->writer->beginBlock($output, "Set folder permissions");
        if ($options["global"]) {
            $this->filesystem->chownRecursive(
                $instance_path,
                $user_name,
                "doil"
            );
            $this->filesystem->chmod($instance_path, 0775, true);
            $this->filesystem->chmodDirsOnly($instance_path, 02775);
        } else {
            $this->filesystem->chownRecursive(
                $instance_path,
                $user_name,
                $user_name
            );
        }
        $this->writer->endBlock();

        // copy necessary files
        $this->writer->beginBlock($output, "Copy necessary files");
        $this->filesystem->copy(
            "/usr/local/share/doil/templates/minion/run-supervisor.sh",
            $instance_path . "/conf/run-supervisor.sh"
        );
        $this->filesystem->copy(
            "/usr/local/share/doil/templates/minion/salt-minion.conf",
            $instance_path . "/conf/salt-minion.conf"
        );
        $this->filesystem->copy(
            "/usr/local/share/doil/templates/minion/docker-compose.yml",
            $instance_path . "/docker-compose.yml"
        );
        $this->filesystem->copy(
            "/usr/local/share/doil/stack/config/minion.cnf",
            $instance_path . "/conf/minion.cnf"
        );
        $this->writer->endBlock();

        // setting up project config
        $this->writer->beginBlock($output, "Setting up configuration");
        $this->project_config = $this->project_config
            ->withName($options["name"])
            ->withRepositoryName($options["repo"])
            ->withRepositoryUrl($options["repo_url"])
            ->withRepositoryBranch($options["branch"])
            ->withPhpVersion($options["phpversion"])
        ;
        $this->filesystem->saveToJsonFile($instance_path . "/conf/project_config.json", [$this->project_config]);
        $this->writer->endBlock();

        // copy ilias
        $this->writer->beginBlock($output, "Copying ilias to target");
        $git_path = Filesystem::DOIL_PATH_SHARE . "/repositories/" . $options["repo"];
        if (! $options["use_global_repo"]) {
            $git_path = $home_dir . "/.doil/repositories/" . $options["repo"];
        }

        $this->filesystem->copyDirectory(
            $git_path,
            $instance_path . "/volumes/ilias/.git"
        );

        $this->git->setLocalConfig($instance_path . "/volumes/ilias", "core.fileMode", "false");
        $this->git->setLocalConfig($instance_path . "/volumes/ilias", "--bool", "core.bare", "false");
        $this->git->setLocalConfig(
            $instance_path . "/volumes/ilias",
            "remote.origin.fetch",
            "+refs/heads/*:refs/remotes/origin/*"
        );
        $this->git->checkoutRemote($instance_path . "/volumes/ilias", $options["branch"]);
        $this->writer->endBlock();

        // preparing docker files
        $this->writer->beginBlock($output, "Set up docker files");
        $this->filesystem->replaceStringInFile(
            $instance_path . "/docker-compose.yml",
            "%TPL_PROJECT_NAME%",
            $options["name"]
        );
        $this->filesystem->replaceStringInFile(
            $instance_path . "/docker-compose.yml",
            "%TPL_PROJECT_DOMAINNAME%",
            $suffix
        );
        $this->writer->endBlock();

        // building minion image
        $this->writer->beginBlock($output, "Building minion image");
        $this->docker->runContainer($instance_name);
        $usr_id = (string) $this->posix->getUserId();
        $group_id = (string) $this->posix->getGroupId();
        $this->docker->executeDockerCommand($instance_name, "usermod -u $usr_id www-data");
        $this->docker->executeDockerCommand($instance_name, "groupmod -g $group_id www-data");
        $this->docker->executeDockerCommand($instance_name, "/etc/init.d/mariadb start");
        sleep(5);
        $this->docker->executeDockerCommand($instance_name, "/etc/init.d/mariadb stop");

        $this->docker->copy($instance_name, "/var/log/apache2/", $instance_path . "/volumes/logs/");
        $this->docker->copy($instance_name, "/etc/mysql/", $instance_path . "/volumes/etc/");
        $this->docker->copy($instance_name, "/var/lib/mysql/", $instance_path . "/volumes/");

        $this->docker->commit($instance_name);
        $this->docker->stop($instance_name);
        $this->docker->removeContainer($instance_name);
        sleep(5);
        $this->docker->startContainerByDockerCompose($instance_path);
        $this->docker->executeCommand($instance_path, $options["name"], "/bin/bash", "-c", "chown -R mysql:mysql var/lib/mysql &>/dev/null");
        $this->docker->executeCommand($instance_path, $options["name"], "/bin/bash", "-c", "/etc/init.d/mariadb start &>/dev/null");
        sleep(5);
        $this->writer->endBlock();

        $ilias_version = $this->ilias_info->getIliasVersion($instance_path);

        // set grains
        $this->writer->beginBlock($output, "Setting up instance configuration");
        $mysql_password = $this->generatePassword(16);
        $cron_password = "not-needed";
        if ($ilias_version < 9) {
            $cron_password = $this->generatePassword(16);
        }
        $host = explode("=", $this->filesystem->getLineInFile("/etc/doil/doil.conf", "host"));
        $this->docker->setGrain($instance_salt_name, "mpass", "${mysql_password}");
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "cpass", "${cron_password}");
        sleep(1);
        $doil_domain = "http://" . $host[1] . "/" . $options["name"];
        $this->docker->setGrain($instance_salt_name, "doil_domain", "${doil_domain}");
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "doil_project_name", "${options['name']}");
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "doil_host_system", "linux");
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "ilias_version", "${ilias_version}");
        $this->docker->commit($instance_name);
        $this->docker->executeDockerCommand("doil_saltmain", "salt \"" . $instance_salt_name . "\" saltutil.refresh_grains");
        $this->writer->endBlock();

        $this->docker->executeDockerCommand($instance_name, "git config --global --add safe.directory \"*\"");
        // apply base state
        $this->writer->beginBlock($output, "Apply base state");
        $this->docker->applyState($instance_salt_name, "base");
        $this->writer->endBlock();

        // apply apache state
        $this->writer->beginBlock($output, "Apply apache state");
        $this->docker->applyState($instance_salt_name, "apache");
        $this->writer->endBlock();

        // apply dev state
        $this->writer->beginBlock($output, "Apply dev state");
        $this->docker->applyState($instance_salt_name, "dev");
        $this->writer->endBlock();

        // apply php state
        $this->writer->beginBlock($output, "Apply php state");
        $this->docker->applyState($instance_salt_name, "php" . $options["phpversion"]);
        $this->writer->endBlock();

        // apply ilias state
        $this->writer->beginBlock($output, "Apply ilias state");
        $this->docker->applyState($instance_salt_name, "ilias");
        $this->writer->endBlock();

        // apply npm-update state
        if ($ilias_version >= 9.0) {
            $this->writer->beginBlock($output, "Apply nodejs state");
            $this->docker->applyState($instance_salt_name, "nodejs");
            $this->writer->endBlock();
        }

        // apply composer state
        $this->writer->beginBlock($output, "Apply composer state");
        $this->docker->applyState($instance_salt_name, $this->getComposerVersion($ilias_version));
        $this->writer->endBlock();

        // apply access state
        $this->writer->beginBlock($output, "Apply access state");
        $this->docker->applyState($instance_salt_name, "access");
        $this->writer->endBlock();

        // finalizing docker image
        $this->writer->beginBlock($output, "Finalizing docker image");
        $this->docker->commit($instance_name);
        $this->writer->endBlock();

        $this->docker->stopContainerByDockerCompose($instance_path);

        // create README.md file for instance
        if (! $options["skip_readme"]) {
            $this->writer->beginBlock($output, "Copy README to project");
            $readme_path = $instance_path . "/README.md";
            $this->filesystem->copy("/usr/local/share/doil/templates/minion/README.md", $readme_path);
            $this->filesystem->replaceStringInFile($readme_path, "%TPL_PROJECT_NAME%", $options["name"]);
            $this->filesystem->replaceStringInFile($readme_path, "%GRAIN_MYSQL_PASSWORD%", $mysql_password);
            $this->filesystem->replaceStringInFile($readme_path, "%GRAIN_CRON_PASSWORD%", $cron_password);
            $this->writer->endBlock();
        }

        // set folder permissions
        $permission_dirs = [
            "conf",
            "volumes/data",
            "volumes/db",
            "volumes/ilias",
            "volumes/etc/apache2",
            "volumes/etc/php",
            "volumes/index",
            "volumes/logs"
        ];

        $permission_files = [
            "docker-compose.yml",
            "README.md",
        ];

        $this->writer->beginBlock($output, "Set folder permissions");
        if ($options["global"]) {
            foreach ($permission_dirs as $permission_dir) {
                $this->filesystem->chownRecursive(
                    $instance_path . "/" . $permission_dir,
                    $user_name,
                    "doil"
                );
                $this->filesystem->chmodDirsOnly($instance_path . "/" . $permission_dir, 02775);
            }
            foreach ($permission_files as $permission_file) {
                $this->filesystem->chmod($instance_path . "/" . $permission_file, 0775, true);
            }
        } else {
            foreach ($permission_dirs as $permission_dir) {
                $this->filesystem->chownRecursive(
                    $instance_path . "/" . $permission_dir,
                    $user_name,
                    $user_name
                );
            }
            foreach ($permission_files as $permission_file) {
                $this->filesystem->chownRecursive(
                    $instance_path . "/" . $permission_file,
                    $user_name,
                    $user_name
                );
            }
        }
        $this->writer->endBlock();

        $this->writer->endBlock();

        $flag = "";
        if ($options["global"]) {
            $flag = " -g";
        }

        $output->writeln("Please start the created instance by <fg=gray>doil up {$options["name"]}$flag</>.");
        return Command::SUCCESS;
    }

    protected function gatherOptionData(InputInterface $input, OutputInterface $output) : array
    {
        $options = [];

        $helper = $this->getHelper('question');
        $name = $input->getOption("name");
        $repo = $input->getOption("repo");
        $branch = $input->getOption("branch");
        $php_version = $input->getOption("phpversion");
        $target = $input->getOption("target");
        $global = $input->getOption("global");

        // Name
        if (is_null($name)) {
            $question = new Question("Please enter a name for the instance to create: ");
            $question->setNormalizer(function ($v) {
                return $v ? trim($v) : '';
            });
            $question->setValidator($this->checkName());

            $name = $helper->ask($input, $output, $question);
        }
        call_user_func($this->checkName(), $name);
        $options["name"] = $name;

        // Repo
        if (is_null($repo)) {
            $local_repos = $this->repo_manager->getLocalRepos();
            $local_repos = array_map(function (Repo $a) {
                return "Local - " . $a->getName() . " - " . $a->getUrl();
            }, $local_repos);

            $global_repos = $this->repo_manager->getGlobalRepos();
            $global_repos = array_map(function (Repo $a) {
                return "Global - " . $a->getName() . " - " . $a->getUrl();
            }, $global_repos);

            $question = new ChoiceQuestion(
                "Please select a repository to create from:",
                array_merge($local_repos, $global_repos),
                0
            );
            $question->setErrorMessage("Repository %s is invalid!");

            list($repo_type, $repo_name, $repo_url) = explode(" - ", $helper->ask($input, $output, $question));

            $options["repo"] = $repo_name;
            $options["repo_url"] = $repo_url;
            $options["use_global_repo"] = true;
            if ($repo_type == "Local") {
                $options["use_global_repo"] = false;
            }
        } else {
            $use_global_repo = $input->getOption("use-global-repo");

            if ($use_global_repo) {
                $options["repo_path"] = self::GLOBAL_REPO_PATH . "/" . $repo;
                $r = $this->repo_manager->getGlobalRepoByName($repo);
            }

            if (!$use_global_repo) {
                $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
                $options["repo_path"] = $home_dir . self::LOCAL_REPO_PATH . "/" . $repo;
                $r = $this->repo_manager->getLocalRepoByName($repo);
            }

            $options["repo"] = $r->getName();
            $options["repo_url"] = $r->getUrl();
            $options["use_global_repo"] = $use_global_repo;
        }

        // Branch
        if (is_null($branch)) {
            $path = self::GLOBAL_REPO_PATH . "/" . $options["repo"];
            if (!$options["use_global_repo"]) {
                $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
                $path = $home_dir . self::LOCAL_REPO_PATH . "/" . $options["repo"];
            }

            if (!$this->filesystem->exists($path)) {
                $question = new ConfirmationQuestion(
                    "The selected repo " . $options["repo"] . " is not cloned to disk yet. Want to clone it now? [Yn]: ",
                    true
                );

                if ($helper->ask($input, $output, $question)) {
                    $this->writer->beginBlock($output, "Clone repo. This will take a while. Please be patient");
                    $this->git->cloneBare($options["repo_url"], $path);
                    $this->writer->endBlock();

                }
            }

            if ($this->filesystem->exists($path)) {
                $branches = $this->getBranches($output, $path, $options["repo_url"]);

                $question = new ChoiceQuestion(
                    "Please select a branch to create from:",
                    $branches,
                    0
                );
                $question->setErrorMessage("Branch %s is invalid!");
            } else {
                $question = new Question("Please enter the branch name: ");
            }
            $branch = $helper->ask($input, $output, $question);
        }
        call_user_func($this->checkBranch(), $branch);
        $options["branch"] = $branch;

        // PHP-Version
        if (is_null($php_version)) {
            $question = new Question("Please enter the php version you want (format=*.*) : ");
            $question->setNormalizer(function ($v) {
                return $v ? trim($v) : '';
            });
            $question->setValidator($this->checkPHPVersion());
            $php_version = $helper->ask($input, $output, $question);
        }
        call_user_func($this->checkPHPVersion(), $php_version);
        $options["phpversion"] = $php_version;

        $options["xdebug"] = false;
        $options["global"] = $global;

        if ($global) {
            $target = explode("=", $this->filesystem->getLineInFile("/etc/doil/doil.conf", "global_instances_path") ?? "")[1];
            if (! $target) {
                $target = "";
            }
            call_user_func($this->checkGlobalTarget(), $target);
        }

        $options["skip_readme"] = false;

        // Target
        if (is_null($target) && !$global) {
            $question = new Question("Please enter a target where doil should install " . $options["name"] . ". Leave blank for current directory. : ");
            $question->setNormalizer($this->normalizeTarget());
            $question->setValidator($this->checkTarget());
            $target = $helper->ask($input, $output, $question);
        }
        call_user_func($this->normalizeTarget(), $target);
        call_user_func($this->checkTarget(), $target);
        $options["target"] = $target;

        return $options;
    }

    protected function checkName() : Closure
    {
        return function(?string $name) {
            if (is_null($name) || "" == $name) {
                throw new RuntimeException("Name of the instance cannot be empty!");
            }
            if (! preg_match("/^[a-z0-9_]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only lowercase letters, numbers and underscores are allowed!");
            }

            return $name;
        };
    }

    protected function checkBranch() : Closure
    {
        return function(?string $branch) {
            if (is_null($branch) || "" == $branch) {
                throw new RuntimeException("Branch can not be null!");
            }
        };
    }

    protected function checkPHPVersion() : Closure
    {
        return function(?string $phpversion) {
            if (is_null($phpversion) || "" == $phpversion) {
                throw new RuntimeException("PHP version can not be null!");
            }
            if (!preg_match("/^\d\.\d$/", $phpversion)) {
                throw new RuntimeException("PHP version must be formatted like *.* (7.4).");
            }
            return $phpversion;
        };
    }

    protected function normalizeTarget() : Closure
    {
        return function(?string $v) : string {
            if (is_null($v) || $v == "") {
                return $this->filesystem->getCurrentWorkingDirectory();
            }
            return realpath(trim($v)) ?: "";
        };
    }

    protected function checkTarget() : Closure
    {
        return function(string $t) {
            if (! $this->filesystem->exists($t)) {
                throw new RuntimeException("the path '$t' does not exists!");
            }
            if (! $this->filesystem->hasWriteAccess($t)) {
                throw new RuntimeException("the path '$t' is not writeable!");
            }
            return $t;
        };
    }
    protected function checkGlobalTarget() : Closure
    {
        return function(string $t) {
            if (is_null($t) || $t == "") {
                throw new RuntimeException("Missing config entry 'global_instances_path'. Please add this entry to /etc/doil/doil.conf to create global instances.");
            }
            if (stristr($t, "/home/") !== false) {
                throw new RuntimeException("Global instances must not be created below /home directory. Please change the entry in /etc/doil/doil.conf.");
            }
        };
    }

    protected function getBranches(OutputInterface $output, string $path, string $url) : array
    {
        $this->writer->beginBlock($output, "Update repo $url");
        $this->git->setLocalConfig(
            $path,
            "remote.origin.fetch",
            "+refs/heads/*:refs/heads/*"
        );
        $this->git->fetchBare($path);
        $branches = $this->git->getBranches($path);
        $this->writer->endBlock();
        return $branches;
    }

    protected function getComposerVersion(string $ilias_version) : string
    {
        if ($ilias_version > 6.9) {
            return "composer2";
        }

        if ($ilias_version < 6.0) {
            return "composer54";
        }

        return "composer";
    }

    public function generatePassword(int $length) : string
    {
        $bytes = openssl_random_pseudo_bytes($length);
        return bin2hex($bytes);
    }
}
