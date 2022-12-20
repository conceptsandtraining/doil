<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

use CaT\Doil\App;
use Pimple\Container;
use CaT\Doil\Commands\Mail;
use CaT\Doil\Commands\Repo;
use CaT\Doil\Commands\Pack;
use CaT\Doil\Commands\Salt;
use CaT\Doil\Commands\User;
use CaT\Doil\Commands\Proxy;
use CaT\Doil\Commands\System;
use CaT\Doil\Lib\Git\GitShell;
use CaT\Doil\Lib\ProjectConfig;
use CaT\Doil\Commands\Instances;
use CaT\Doil\Lib\Posix\PosixShell;
use CaT\Doil\Lib\Linux\LinuxShell;
use CaT\Doil\Lib\Docker\DockerShell;
use CaT\Doil\Lib\Logger\LoggerFactory;
use CaT\Doil\Commands\Repo\RepoManager;
use CaT\Doil\Lib\FileSystem\FilesystemShell;
use CaT\Doil\Lib\ConsoleOutput\CommandWriter;

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
require_once __DIR__ . "/../vendor/autoload.php";

$c = buildContainerForApp();
$app = $c["app"];
$app->run();

function buildContainerForApp() : Container
{
    $c = new Container();

    $c["app"] = function($c) {
        return new App(
            $c["command.instances.apply"],
            $c["command.instances.create"],
            $c["command.instances.delete"],
            $c["command.instances.down"],
            $c["command.instances.exec"],
            $c["command.instances.list"],
            $c["command.instances.login"],
            $c["command.instances.path"],
            $c["command.instances.status"],
            $c["command.instances.up"],
            $c["command.mail.change.password"],
            $c["command.mail.down"],
            $c["command.mail.login"],
            $c["command.mail.restart"],
            $c["command.mail.up"],
            $c["command.pack.export"],
            $c["command.pack.import"],
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
            $c["command.system.uninstall"],
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
            $c["posix.shell"]
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
            $c["command.writer"]
        );
    };

    $c["command.pack.import"] = function($c) {
        return new Pack\ImportCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["repo.manager"],
            $c["command.writer"]
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

    $c["command.system.uninstall"] = function($c) {
        return new System\UninstallCommand(
            $c["docker.shell"],
            $c["posix.shell"],
            $c["filesystem.shell"],
            $c["linux.shell"],
            $c["user.manager"],
            $c["command.writer"]
        );
    };

    $c["command.user.add"] = function($c) {
        return new User\AddCommand(
            $c["user.manager"],
            $c["posix.shell"],
            $c["linux.shell"],
            $c["filesystem.shell"],
            $c["command.writer"]
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