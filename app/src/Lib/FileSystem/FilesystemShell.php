<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\FileSystem;

use ZipArchive;
use SplFileInfo;
use RegexIterator;
use RecursiveIteratorIterator;
use RecursiveDirectoryIterator;
use Symfony\Component\Filesystem\Filesystem as SymfonyFileSystem;

class FilesystemShell implements Filesystem
{
    protected SymfonyFileSystem $symfony_file_system;

    public function __construct(SymfonyFileSystem $symfony_file_system)
    {
        $this->symfony_file_system = $symfony_file_system;
    }

    public function getCurrentWorkingDirectory() : string
    {
        return getcwd();
    }

    public function getFilenameFromPath(string $path) : string
    {
        return pathinfo($path, PATHINFO_FILENAME);
    }

    public function exists(string $path) : bool
    {
        return $this->symfony_file_system->exists($path);
    }

    public function getFilesInPath(string $path) : array
    {
        return array_values(array_diff(scandir($path), ['.', '..']));
    }

    public function remove(string $path) : void
    {
        if(file_exists($path)){
            $this->symfony_file_system->remove($path);
        }
    }

    public function hasWriteAccess(string $path) : bool
    {
        return is_writable($path);
    }

    public function makeDirectoryRecursive(string $path) : void
    {
        if ($this->exists($path)) {
            return;
        }
        mkdir($path, 0777, true);
    }

    public function copy(string $from, string $to) : void
    {
        $this->symfony_file_system->copy($from, $to, true);
    }

    public function copyDirectory(string $from, string $to) : void
    {
        $this->symfony_file_system->mirror($from, $to);
    }

    public function chownRecursive(string $path, string $owner, string $group) : void
    {
        $this->symfony_file_system->chown($path, $owner, true);
        $this->symfony_file_system->chgrp($path, $group, true);
    }

    public function chmod(string $path, int $mode) : void
    {
        $this->symfony_file_system->chmod($path, $mode);
    }

    public function symlink(string $from, string $to) : void
    {
        $this->symfony_file_system->symlink($from, $to);
    }

    public function readLink(string $path) : string
    {
        return readlink($path);
    }

    public function zip(string $name) : void
    {
        $rootPath = realpath($name);

        $zip = new ZipArchive();
        $zip->open($name . ".zip", ZipArchive::CREATE | ZipArchive::OVERWRITE);

        /** @var SplFileInfo[] $files */
        $files = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($rootPath),
            RecursiveIteratorIterator::LEAVES_ONLY
        );

        foreach ($files as $file)
        {
            if (!$file->isDir())
            {
                $filePath = $file->getRealPath();
                $relativePath = substr($filePath, strlen($rootPath) + 1);

                $zip->addFile($filePath, $relativePath);
            }
        }

        $zip->close();
    }

    public function unzip(string $from, string $to) : void
    {
        $path = pathinfo(realpath($from), PATHINFO_DIRNAME);

        $zip = new ZipArchive;
        if ($zip->open($from) !== true) {
            throw new \Exception("Cant open $from.");
        }

        $zip->extractTo($path . DIRECTORY_SEPARATOR . $to);
        $zip->close();
    }

    public function searchForFileRecursive(string $path, string $pattern) : ?string
    {
        $dir = new RecursiveDirectoryIterator($path);
        $ite = new RecursiveIteratorIterator($dir);
        $files = new RegexIterator($ite, $pattern, RegexIterator::MATCH);

        foreach ($files as $file) {
            return $file->getPathname();
        }

        return null;
    }

    public function replaceStringInFile(string $path, string $needle, string $substitute) : void
    {
        $data = file($path);
        $data = str_replace($needle, $substitute, $data);
        file_put_contents($path, implode("", $data));
    }

    public function replaceLineInFile(string $path, string $needle, string $substitute) : void
    {
        $text = preg_replace($needle, $substitute, file_get_contents($path), 1, $count);

        if ($count) {
            file_put_contents($path, $text);
        }
    }

    public function getLineInFile(string $path, string $needle) : ?string
    {
        $data = file($path);
        foreach ($data as $value) {
            if (stristr($value, $needle)) {
                return $value;
            }
        }
        return null;
    }

    public function saveToJsonFile(string $path, array $objects) : void
    {
        $json_data = json_encode(serialize($objects));
        file_put_contents($path, $json_data);
    }

    public function readFromJsonFile(string $path) : array
    {
        $json_data = file_get_contents($path);
        if (is_null($json_data) || $json_data == "") {
            return [];
        }
        return unserialize(json_decode($json_data));
    }

    public function grepMysqlPasswordFromFile(string $path) : string
    {
        $content = file_get_contents($path);

        if (preg_match("/^MYSQL_PASSWORD.*$/m", $content, $matches)) {
            return trim(strstr($matches[0], " "));
        }

        return "";
    }
}