<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

use CaT\Doil\App;
use Pimple\Container;
use CaT\Doil\Commands\Mail;
use CaT\Doil\Commands\Repo;
use CaT\Doil\Commands\Pack;
use CaT\Doil\Commands\Salt;
use CaT\Doil\Commands\System;
use CaT\Doil\Commands\User;
use CaT\Doil\Setup\Install;
use CaT\Doil\Commands\Proxy;
use CaT\Doil\Lib\Git\GitShell;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Commands\Keycloak;
use CaT\Doil\Lib\System\Update;
use CaT\Doil\Commands\Instances;
use CaT\Doil\Lib\ILIAS\IliasInfo;
use CaT\Doil\Lib\Posix\PosixShell;
use CaT\Doil\Lib\Linux\LinuxShell;
use CaT\Doil\Lib\Docker\DockerShell;
use CaT\Doil\Lib\Config\ConfigReader;
use CaT\Doil\Lib\Logger\LoggerFactory;
use CaT\Doil\Lib\Config\ConfigChecker;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Setup\Server\StartServers;
use CaT\Doil\Lib\ConsoleOutput\SetupWriter;
use CaT\Doil\Lib\FileSystem\FilesystemShell;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;
use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Helper\QuestionHelper;

require_once __DIR__ . "/../vendor/autoload.php";

$command = $argv[1] ?? "";
$script_dir = $argv[2] ?? "";
$home_dir = $argv[3] ?? "";
$user_name = $argv[4] ?? "";

unset($_SERVER['argv'][1]);
unset($_SERVER['argv'][2]);
unset($_SERVER['argv'][3]);
unset($_SERVER['argv'][4]);
unset($_SERVER['argv'][5]);

$_SERVER['argv'] = array_values($_SERVER['argv']);

$c = buildContainerForApp($script_dir, $home_dir, $user_name);

switch ($command) {
    case "install":
        $install = $c["install"];
        $install->run();
        break;
    default:
        $app = $c["app"];
        $app->run();
}

function buildContainerForApp(string $script_dir = "", string $home_dir = "", string $user_name = "") : Container
{
    $c = new Container();

    $c["install"] = function($c) use ($script_dir) {
        return new Install(
            $c["logger"],
            $c["setup.question_helper"],
            $c["setup.output"],
            $c["setup.input"],
            $c["setup.writer"],
            $c["setup.base_directories"],
            $c["setup.base_files"],
            $c["setup.copy"],
            $c["setup.ip"],
            $c["setup.config_reader"],
            $c["setup.config_checker"],
            $c["filesystem.shell"],
            $c["setup.server.start"],
            $script_dir
        );
    };

    $c["setup.server.start"] = function($c) {
        return new StartServers(
            $c["setup.salt"],
            $c["setup.proxy"],
            $c["setup.mail"],
            $c["setup.keycloak"],
        );
    };

    $c["setup.question_helper"] = function($c) {
        return new QuestionHelper();
    };

    $c["setup.output"] = function($c) {
        return new ConsoleOutput();
    };

    $c["setup.input"] = function($c) {
        return new ArgvInput();
    };

    $c["setup.writer"] = function($c) {
        return new SetupWriter();
    };

    $c["setup.base_directories"] = function($c) use ($home_dir, $user_name) {
        return new CaT\Doil\Setup\FileStructure\BaseDirectories(
            $c["filesystem.shell"],
            $home_dir,
            $user_name
        );
    };

    $c["setup.base_files"] = function($c) use ($home_dir, $user_name) {
        return new CaT\Doil\Setup\FileStructure\BaseFiles(
            $c["filesystem.shell"],
            $home_dir,
            $user_name
        );
    };

    $c["setup.copy"] = function($c) {
        return new CaT\Doil\Setup\CopyFiles\Copy(
            $c["filesystem.shell"]
        );
    };

    $c["setup.ip"] = function($c) {
        return new CaT\Doil\Setup\IP\IP(
            $c["filesystem.shell"],
        );
    };

    $c["setup.config_reader"] = function($c) {
        return new ConfigReader(
            $c["setup.config"],
            $c["filesystem.shell"],
        );
    };

    $c["setup.config_checker"] = function($c) {
        return new ConfigChecker(
            $c["filesystem.shell"]
        );
    };

    $c["setup.config"] = function($c) {
        return new CaT\Doil\Lib\Config\Config();
    };

    $c["setup.salt"] = function($c) {
        return new CaT\Doil\Setup\Server\Salt();
    };

    $c["setup.proxy"] = function($c) {
        return new CaT\Doil\Setup\Server\Proxy(
            $c["filesystem.shell"]
        );
    };

    $c["setup.mail"] = function($c) {
        return new CaT\Doil\Setup\Server\Mail();
    };

    $c["setup.keycloak"] = function($c) {
        return new CaT\Doil\Setup\Server\Keycloak(
            $c["filesystem.shell"]
        );
    };


    $c["app"] = function($c) {
        return new App(
            $c["command.instances.apply"],
            $c["command.instances.create"],
            $c["command.instances.csp"],
            $c["command.instances.delete"],
            $c["command.instances.down"],
            $c["command.instances.exec"],
            $c["command.instances.list"],
            $c["command.instances.login"],
            $c["command.instances.path"],
            $c["command.instances.restart"],
            $c["command.instances.set.update.token"],
            $c["command.instances.status"],
            $c["command.instances.up"],
            $c["command.keycloak.down"],
            $c["command.keycloak.login"],
            $c["command.keycloak.restart"],
            $c["command.keycloak.up"],
            $c["command.mail.change.password"],
            $c["command.mail.down"],
            $c["command.mail.login"],
            $c["command.mail.restart"],
            $c["command.mail.up"],
            $c["command.pack.export"],
            $c["command.pack.import"],
            $c["command.pack.create"],
            $c["command.proxy.login"],
            $c["command.proxy.prune"],
            $c["command.proxy.reload"],
            $c["command.proxy.restart"],
            $c["command.proxy.up"],
            $c["command.proxy.down"],
            $c["command.repo.add"],
            $c["command.repo.delete"],
            $c["command.repo.list"],
            $c["command.repo.update"],
            $c["command.salt.login"],
            $c["command.salt.prune"],
            $c["command.salt.restart"],
            $c["command.salt.up"],
            $c["command.salt.states"],
            $c["command.salt.down"],
            $c["command.system.update"],
            $c["command.user.add"],
            $c["command.user.delete"],
            $c["command.user.list"]
        );
    };

    $c["logger"] = function() {
        return new LoggerFactory();
    };

    $c["docker.shell"] = function($c) {
        return new DockerShell(
            $c["logger"],
            $c["posix.shell"],
            $c["filesystem.shell"]
        );
    };

    $c["ilias.info"] = function($c) {
        return new IliasInfo(
            $c["filesystem.shell"]
        );
    };

    $c["git.shell"] = function($c) {
        return new GitShell(
            $c["logger"]
        );
    };

    $c["repo.manager"] = function($c) {
        return new RepoManager(
            $c["git.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"]
        );
    };

    $c["posix.shell"] = function() {
        return new PosixShell();
    };

    $c["filesystem.shell"] = function($c) {
        return new FilesystemShell(
            $c["symfony.filesystem"]
        );
    };

    $c["symfony.filesystem"] = function() {
        return new Symfony\Component\Filesystem\Filesystem();
    };

    $c["user.manager"] = function($c) {
        return new User\UserManager(
            $c["filesystem.shell"]
        );
    };

    $c["linux.shell"] = function($c) {
        return new LinuxShell(
            $c["logger"]
        );
    };

    $c["system.update"] = function($c) {
        return new Update(
            $c["logger"],
            $c["setup.output"],
            $c["setup.input"],
            $c["command.writer"],
            $c["git.shell"],
            $c["filesystem.shell"],
            $c["setup.config_reader"],
            $c["setup.config_checker"],
            $c["setup.copy"],
            $c["docker.shell"],
            $c["posix.shell"],
            $c["setup.salt"],
            $c["setup.proxy"],
            $c["setup.mail"],
            $c["setup.keycloak"],
            $c["setup.server.start"],
        );
    };

    $c["command.writer"] = function() {
        return new CommandWriter();
    };

    $c["project.config"] = function() {
        return new ProjectConfig();
    };

    $c["command.instances.apply"] = function($c) {
        return new Instances\ApplyCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.create"] = function($c) {
        return new Instances\CreateCommand(
            $c["docker.shell"],
            $c["repo.manager"],
            $c["git.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["linux.shell"],
            $c["project.config"],
            $c["command.writer"],
            $c["ilias.info"]
        );
    };

    $c["command.instances.csp"] = function($c) {
        return new Instances\CSPCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.delete"] = function($c) {
        return new Instances\DeleteCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.down"] = function($c) {
        return new Instances\DownCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.exec"] = function($c) {
        return new Instances\ExecCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.list"] = function($c) {
        return new Instances\ListCommand(
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.login"] = function($c) {
        return new Instances\LoginCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"]
        );
    };

    $c["command.instances.path"] = function($c) {
        return new Instances\PathCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.restart"] = function($c) {
        return new Instances\RestartCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.set.update.token"] = function($c) {
        return new Instances\SetUpdateTokenCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.instances.status"] = function($c) {
        return new Instances\StatusCommand(
            $c["docker.shell"]
        );
    };

    $c["command.instances.up"] = function($c) {
        return new Instances\UpCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
        );
    };

    $c["command.keycloak.down"] = function($c) {
        return new Keycloak\DownCommand(
            $c["docker.shell"],
            $c["command.writer"],
            $c["filesystem.shell"]
        );
    };

    $c["command.keycloak.login"] = function($c) {
        return new Keycloak\LoginCommand(
            $c["docker.shell"],
            $c["filesystem.shell"]
        );
    };

    $c["command.keycloak.restart"] = function($c) {
        return new Keycloak\RestartCommand(
            $c["docker.shell"],
            $c["command.writer"],
            $c["filesystem.shell"]
        );
    };

    $c["command.keycloak.up"] = function($c) {
        return new Keycloak\UpCommand(
            $c["docker.shell"],
            $c["command.writer"],
            $c["filesystem.shell"]
        );
    };

    $c["command.mail.change.password"] = function($c) {
        return new Mail\ChangePasswordCommand(
            $c["docker.shell"],
            $c["command.writer"],
            $c["posix.shell"]
        );
    };

    $c["command.mail.down"] = function($c) {
        return new Mail\DownCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.mail.login"] = function($c) {
        return new Mail\LoginCommand(
            $c["docker.shell"]
        );
    };

    $c["command.mail.restart"] = function($c) {
        return new Mail\RestartCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.mail.up"] = function($c) {
        return new Mail\UpCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.pack.export"] = function($c) {
        return new Pack\ExportCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["command.writer"],
            $c["project.config"],
            $c["git.shell"],
            $c["repo.manager"],
            $c["ilias.info"]
        );
    };

    $c["command.pack.import"] = function($c) {
        return new Pack\ImportCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["repo.manager"],
            $c["command.writer"],
            $c["ilias.info"]
        );
    };

    $c["command.pack.create"] = function($c) {
        return new Pack\PackCreateCommand(
            $c["docker.shell"],
            $c["repo.manager"],
            $c["git.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["linux.shell"],
            $c["project.config"],
            $c["command.writer"],
            $c["ilias.info"]
        );
    };

    $c["command.proxy.down"] = function($c) {
        return new Proxy\DownCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.proxy.login"] = function($c) {
        return new Proxy\LoginCommand(
            $c["docker.shell"]
        );
    };

    $c["command.proxy.prune"] = function($c) {
        return new Proxy\PruneCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.proxy.reload"] = function($c) {
        return new Proxy\ReloadCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.proxy.restart"] = function($c) {
        return new Proxy\RestartCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.proxy.up"] = function($c) {
        return new Proxy\UpCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.repo.add"] = function($c) {
        return new Repo\AddCommand(
            $c["repo.manager"],
            $c["command.writer"]
        );
    };

    $c["command.repo.delete"] = function($c) {
        return new Repo\DeleteCommand(
            $c["repo.manager"],
            $c["command.writer"]
        );
    };

    $c["command.repo.list"] = function($c) {
        return new Repo\ListCommand(
            $c["repo.manager"]
        );
    };

    $c["command.repo.update"] = function($c) {
        return new Repo\UpdateCommand(
            $c["repo.manager"],
            $c["command.writer"]
        );
    };

    $c["command.salt.down"] = function($c) {
        return new Salt\DownCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.salt.login"] = function($c) {
        return new Salt\LoginCommand(
            $c["docker.shell"]
        );
    };

    $c["command.salt.prune"] = function($c) {
        return new Salt\PruneCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.salt.restart"] = function($c) {
        return new Salt\RestartCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.salt.states"] = function($c) {
        return new Salt\StatesCommand(
            $c["filesystem.shell"]
        );
    };

    $c["command.salt.up"] = function($c) {
        return new Salt\UpCommand(
            $c["docker.shell"],
            $c["command.writer"]
        );
    };

    $c["command.system.update"] = function($c) {
        return new System\UpdateCommand(
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["git.shell"],
            $c["system.update"],
            $c["command.writer"]
        );
    };

    $c["command.user.add"] = function($c) {
        return new User\AddCommand(
            $c["user.manager"],
            $c["posix.shell"],
            $c["linux.shell"],
            $c["filesystem.shell"],
            $c["command.writer"],
            $c["repo.manager"]
        );
    };

    $c["command.user.delete"] = function($c) {
        return new User\DeleteCommand(
            $c["user.manager"],
            $c["posix.shell"],
            $c["linux.shell"],
            $c["command.writer"]
        );
    };

    $c["command.user.list"] = function($c) {
        return new User\ListCommand(
            $c["user.manager"]
        );
    };

    return $c;
}