<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\FileSystem;

interface Filesystem
{
    public const DOIL_PATH_MAIN_CONFIG = "/etc/doil";
    public const DOIL_PATH_LIB = "/usr/local/lib/doil";
    public const DOIL_PATH_SHARE = "/usr/local/share/doil";
    public const DOIL_PATH_BIN = "/usr/local/bin/doil";

    public function getCurrentWorkingDirectory() : string;
    public function getFilenameFromPath(string $path) : string;
    public function getDirFromPath(string $path) : string;
    public function exists(string $path) : bool;
    public function getFilesInPath(string $path) : array;
    public function remove(string $path) : void;
    public function hasWriteAccess(string $path) : bool;
    public function makeDirectoryRecursive(string $path) : void;
    public function copy(string $from, string $to) : void;
    public function copyDirectory(string $from, string $to) : void;
    public function chownRecursive(string $path, string $owner, string $group) : void;
    public function chmod(string $path, int $mode) : void;
    public function symlink(string $from, string $to) : void;
    public function readLink(string $path) : string;
    public function zip(string $name) : void;
    public function unzip(string $from, string $to) : void;
    public function searchForFileRecursive(string $path, string $pattern) : ?string;
    public function replaceStringInFile(string $path, string $needle, string $substitute) : void;
    public function replaceLineInFile(string $path, string $needle, string $substitute) : void;
    public function getLineInFile(string $path, string $needle) : ?string;
    public function saveToJsonFile(string $path, array $objects) : void;
    public function readFromJsonFile(string $path) : array;
    public function grepMysqlPasswordFromFile(string $path) : string;
    public function addToGitConfig(string $path, string $section, string $line) : void;
}