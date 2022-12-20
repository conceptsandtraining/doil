<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Commands\Instances;

use Closure;
use RuntimeException;
use CaT\Doil\Lib\Git\Git;
use CaT\Doil\Commands\Repo\Repo;
use CaT\Doil\Lib\Posix\Posix;
use CaT\Doil\Lib\Linux\Linux;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Lib\Docker\Docker;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\ConsoleOutput\Writer;
use CaT\Doil\Lib\FileSystem\Filesystem;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\ConfirmationQuestion;

class CreateCommand extends Command
{
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
        "/volumes/etc/php",
        "/volumes/etc/mysql",
    ];

    protected static $defaultName = "instances:create";
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

    public function __construct(
        Docker $docker,
        RepoManager $repo_manager,
        Git $git,
        Posix $posix,
        Filesystem $filesystem,
        Linux $linux,
        ProjectConfig $project_config,
        Writer $writer
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
    }

    public function configure() : void
    {
        $this
            ->setAliases(["create"])
            ->addOption("name", "e", InputOption::VALUE_OPTIONAL, "Sets the name of the instance")
            ->addOption("repo", "r", InputOption::VALUE_OPTIONAL, "Sets the repository to use")
            ->addOption("use-global-repo", "u", InputOption::VALUE_NONE, "Determines if the repo is global one or not")
            ->addOption("branch", "b", InputOption::VALUE_OPTIONAL, "Sets the branch to use")
            ->addOption("phpversion", "p", InputOption::VALUE_OPTIONAL, "Sets the php version to use")
            ->addOption("target", "t", InputOption::VALUE_OPTIONAL, "Sets the target destination for the instance. If the folder does not exist, it will be created")
            ->addOption("xdebug", "x", InputOption::VALUE_NONE, "Determines if xdebug should be installed or not")
            ->addOption("global", "g", InputOption::VALUE_NONE, "Determines if an instance is global or not")
            ->addOption("skip-readme", "s", InputOption::VALUE_NONE, "Doesn't create the README.md file")
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output) : int
    {
        if (! $input->getOption("no-interaction")) {
            $options = $this->getUserInputOptions($input, $output);
        } else {
            $options = $this->getCommandlineOptions($input, $output);
        }

        $instance_path = $options["target"] . "/" . $options["name"];
        $suffix = $options["global"] ? "global" : "local";
        $instance_name = $options["name"] . "_" . $suffix;
        $instance_salt_name = $options["name"] . "." . $suffix;

        if ($this->filesystem->exists($instance_path)) {
            $this->writer->error(
                $output,
                $options["name"] . " already exists!",
                "See <fg=gray>doil instances:create --help</> for more information."
            );
            return Command::FAILURE;
        }
        // TODO: implement logging

        $this->writer->beginBlock($output, "Creating instance " . $options['name']);

        if (isset($options["repo_path"]) && ! $this->filesystem->exists($options["repo_path"])) {
            $this->writer->beginBlock($output, "Clone repo. This will take a while. Please be patient");
            $this->git->cloneBare($options["repo_url"], $options["repo_path"]);
            $this->writer->endBlock();

            $branches = $this->getBranches($output, $options["repo_path"], $options["repo_url"]);

            if (! in_array($options["branch"], $branches)) {
                throw new RuntimeException($options["branch"] . " is not a branch from " . $options["repo_url"]);
            }
        }

        // update debian image
        $this->writer->beginBlock($output, "Updating debian image");
        $this->docker->pull("debian");
        $this->writer->endBlock();

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
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $this->filesystem->symlink($instance_path, $home_dir . self::LOCAL_INSTANCES_PATH . "/" . $options["name"]);
        }
        $this->writer->endBlock();

        // set folder permissions
        $this->writer->beginBlock($output, "Set folder permissions");
        if ($options["global"]) {
            $this->filesystem->chownRecursive(
                $instance_path,
                $this->posix->getCurrentUserName(),
                "doil"
            );
            $this->filesystem->chmod($instance_path, 02775);
        } else {
            $this->filesystem->chownRecursive(
                $instance_path,
                $this->posix->getCurrentUserName(),
                $this->posix->getCurrentUserName()
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
            "/usr/local/share/doil/templates/minion/Dockerfile",
            $instance_path . "/Dockerfile"
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
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
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
        $this->filesystem->replaceStringInFile(
            $instance_path . "/Dockerfile",
            "%USER_ID%",
            (string) $this->posix->getUserId()
        );
        $this->filesystem->replaceStringInFile(
            $instance_path . "/Dockerfile",
            "%GROUP_ID%",
            (string) $this->posix->getGroupId()
        );
        $this->writer->endBlock();

        // building minion image
        $this->writer->beginBlock($output, "Building minion image. This will take a while. Please be patient");
        $this->docker->build($instance_path, $instance_name);
        $this->docker->runContainer($instance_name);
        $this->docker->executeDockerCommand($instance_name, "apt install -y mariadb-server python3-mysqldb");
        $this->docker->executeDockerCommand($instance_name, "/etc/init.d/mariadb start");
        sleep(5);
        $this->docker->executeDockerCommand($instance_name, "/etc/init.d/mariadb stop");

        $this->docker->copy($instance_name, "/etc/apache2", $instance_path . "/volumes/etc/");
        $this->docker->copy($instance_name, "/etc/php", $instance_path . "/volumes/etc/");
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
        $this->writer->endBlock();

        $this->writer->beginBlock($output, "Checking salt key");
        $salt_keys = [];
        while (! in_array($instance_salt_name, $salt_keys)) {
            $this->docker->executeDockerCommand($instance_name, "killall -9 salt-minion");
            $this->docker->executeDockerCommand($instance_name, "rm -rf /var/lib/salt/pki/minion/*");
            $this->docker->executeDockerCommand("doil_saltmain", "salt-key -d " . $instance_salt_name . " -y");
            $this->docker->executeDockerCommand($instance_name, "salt-minion -d");

            sleep(5);
            $salt_keys = $this->docker->getSaltAcceptedKeys();
        }
        $this->writer->endBlock();

        // set grains
        $this->writer->beginBlock($output, "Setting up instance configuration");
        $mysql_password = $this->generatePassword(16);
        $cron_password = $this->generatePassword(16);
        $host = explode("=", $this->filesystem->getLineInFile("/etc/doil/doil.conf", "host"));
        $this->docker->setGrain($instance_salt_name, "mysql_password", $mysql_password);
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "cron_password", $cron_password);
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "doil_domain", "http://" . $host[1] . "/" . $options["name"]);
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "doil_project_name", $options["name"]);
        sleep(1);
        $this->docker->setGrain($instance_salt_name, "doil_host_system", "linux");
        if ($this->linux->isWSL()) {
            $this->docker->setGrain($instance_salt_name, "doil_host_system", "windows");
        }
        $this->docker->executeDockerCommand("doil_saltmain", "salt \"" . $instance_salt_name . "\" saltutil.refresh_grains");
        $this->writer->endBlock();

        // apply base state
        $this->writer->beginBlock($output, "Apply base state");
        $this->docker->applyState($instance_salt_name, "base");
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
        $this->writer->beginBlock($output, "Apply ilias state ...");
        $this->docker->applyState($instance_salt_name, "ilias");
        $this->writer->endBlock();

        // apply composer state
        $this->writer->beginBlock($output, "Apply composer state");
        $ilias_version = $this->getIliasVersion($instance_path);
        $this->docker->applyState($instance_salt_name, $this->getComposerVersion($ilias_version));
        $this->writer->endBlock();

        // apply auto installer state
        if ($ilias_version > 6.99) {
            $this->writer->beginBlock($output, "Trying auto installer");
            $this->docker->applyState($instance_salt_name, "autoinstall");
            $this->writer->endBlock();
        }

        // apply enable-xdebug state
        if ($options['xdebug']) {
            $this->writer->beginBlock($output, "Apply enable-xdebug state");
            $this->docker->applyState($instance_salt_name, "enable-xdebug");
            $this->writer->endBlock();
        }

        // apply access state
        $this->writer->beginBlock($output, "Apply access state");
        $this->docker->applyState($instance_salt_name, "access");
        $this->writer->endBlock();

        // apply access state
        $this->writer->beginBlock($output, "Apply ilias-postinstall state");
        $this->docker->applyState($instance_salt_name, "ilias-postinstall");
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

        $this->writer->endBlock();

        $flag = "";
        if ($options["global"]) {
            $flag = " -g";
        }

        $output->writeln("Please start the created instance by <fg=gray>doil up {$options["name"]}$flag</>.");

        return Command::SUCCESS;
    }

    protected function getUserInputOptions(InputInterface $input, OutputInterface $output) : array
    {
        $options = [];

        $helper = $this->getHelper('question');

        // Name
        $question = new Question("Please enter a name for the instance to create: ");
        $question->setNormalizer(function($v) { return $v ? trim($v) : ''; });
        $question->setValidator($this->checkName());

        $options["name"] = $helper->ask($input, $output, $question);

        // Repo
        $local_repos = $this->repo_manager->getLocalRepos();
        $local = array_map(function(Repo $a) {
            return "Local - " . $a->getName() . " - " . $a->getUrl();
        }, $local_repos);
        $global_repos = $this->repo_manager->getGlobalRepos();
        $global = array_map(function(Repo $a) {
            return "Global - " . $a->getName() . " - " . $a->getUrl();
        }, $global_repos);

        $question = new ChoiceQuestion(
            "Please select a repository to create from:",
            array_merge($local, $global),
            0
        );
        $question->setErrorMessage("Repository %s is invalid!");

        list($type, $name, $url) = explode(" - ", $helper->ask($input, $output, $question));

        $options["repo"] = $name;
        $options["repo_url"] = $url;
        $options["use_global_repo"] = true;
        if ($type == "Local") {
            $options["use_global_repo"] = false;
        }

        // Branch
        $path = self::GLOBAL_REPO_PATH . "/" . $options["repo"];
        if (! $options["use_global_repo"]) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = $home_dir . self::LOCAL_REPO_PATH . "/" . $options["repo"];
        }

        if (!$this->filesystem->exists($path)) {
            $question = new ConfirmationQuestion(
                "The selected repo $name is not cloned to disk yet. Want to clone it now? [Yn]: ",
                true
            );

            if ($helper->ask($input, $output, $question)) {
                $this->writer->beginBlock($output, "Clone repo. This will take a while. Please be patient");
                $this->git->cloneBare($url, $path);
                $this->writer->endBlock();

            }
        }

        if ($this->filesystem->exists($path)) {
            $branches = $this->getBranches($output, $path, $url);

            $question = new ChoiceQuestion(
                "Please select a branch to create from:",
                $branches,
                0
            );
            $question->setErrorMessage("Branch %s is invalid!");
        } else {
            $question = new Question("Please enter the branch name: ");
        }
        $options["branch"] = $helper->ask($input, $output, $question);

        // PHP-Version
        $question = new Question("Please enter the php version you want (format=*.*) : ");
        $question->setNormalizer(function($v) { return $v ? trim($v) : ''; });
        $question->setValidator($this->checkPHPVersion());
        $options["phpversion"] = $helper->ask($input, $output, $question);

        // Target
        $question = new Question("Please enter a target where doil should install " . $options["name"] . ". Leave blank for current directory. : ");
        $question->setNormalizer($this->normalizeTarget());
        $question->setValidator($this->checkTarget());
        $options["target"] = $helper->ask($input, $output, $question);

        // Install xdebug
        $question = new ConfirmationQuestion(
            "Install xdebug? [yN]: ",
            false
        );
        $options["xdebug"] = $helper->ask($input, $output, $question);

        // Global instance
        $question = new ConfirmationQuestion(
            "Create a global instance? [yN]: ",
            false
        );
        $options["global"] = $helper->ask($input, $output, $question);

        // Skip readme
        $question = new ConfirmationQuestion(
            "Skip creating readme file? [yN]: ",
            false
        );
        $options["skip_readme"] = $helper->ask($input, $output, $question);

        return $options;
    }

    protected function getCommandlineOptions(InputInterface $input, OutputInterface $output) : array
    {
        $name = $input->getOption("name");
        call_user_func($this->checkName(), $name);

        $repo_name = $input->getOption("repo");
        call_user_func($this->checkRepo(), $repo_name);

        $use_global_repo = $input->getOption("use-global-repo");

        $branch = $input->getOption("branch");
        call_user_func($this->checkBranch(), $branch);

        $phpversion = $input->getOption("phpversion");
        $phpversion = call_user_func($this->checkPHPVersion(), $phpversion);

        $target = $input->getOption("target");
        $target = call_user_func($this->normalizeTarget(), $target);
        $target = call_user_func($this->checkTarget(), $target);

        $xdebug = $input->getOption("xdebug");

        $global = $input->getOption("global");

        $skip_readme = $input->getOption("skip-readme");

        if ($use_global_repo) {
            $path = self::GLOBAL_REPO_PATH . "/" . $repo_name;
            $repo = $this->repo_manager->getGlobalRepo($repo_name);
        }

        if (!$use_global_repo) {
            $home_dir = $this->posix->getHomeDirectory($this->posix->getUserId());
            $path = $home_dir . self::LOCAL_REPO_PATH . "/" . $repo_name;
            $repo = $this->repo_manager->getLocalRepo($repo_name);
        }

        return [
            "name" => $name,
            "repo" => $repo->getName(),
            "repo_url" => $repo->getUrl(),
            "repo_path" => $path,
            "use_global_repo" => $use_global_repo,
            "branch" => $branch,
            "phpversion" => $phpversion,
            "target" => $target,
            "xdebug" => $xdebug,
            "global" => $global,
            "skip_readme" => $skip_readme
        ];
    }

    protected function checkName() : Closure
    {
        return function(?string $name) {
            if (is_null($name) || "" == $name) {
                throw new RuntimeException("Name of the instance cannot be empty!");
            }
            if (! preg_match("/^[a-zA-Z0-9_]*$/", $name)) {
                throw new RuntimeException("Invalid characters! Only letters, numbers and underscores are allowed!");
            }

            return $name;
        };
    }

    protected function checkRepo() : Closure
    {
        return function(?string $repo) {
            if (is_null($repo) || "" == $repo) {
                throw new RuntimeException("Repo can not be null!");
            }
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

    protected function getBranches(OutputInterface $output, string $path, string $url) : array
    {
        $this->writer->beginBlock($output, "Update repo $url");
        $this->git->fetchBare($path, $url);
        $branches = $this->git->getBranches($path);
        $this->writer->endBlock();
        return $branches;
    }

    protected function getIliasVersion(string $path) : string
    {
        $ilias_version = $this->filesystem->getLineInFile(
            $path . "/volumes/ilias/include/inc.ilias_version.php",
            "ILIAS_VERSION_NUMERIC"
        );

        preg_match("/\d.\d/", $ilias_version, $version);

        return $version[0];
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
