<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib;

use Symfony\Component\Console\Output\OutputInterface;

trait CLIHelper
{
    public function grepMysqlPasswordFromFile(string $path) : string
    {
        $content = file_get_contents($path);

        if (preg_match("/^MYSQL_PASSWORD.*$/m", $content, $matches)) {
            return trim(strstr($matches[0], " "));
        }

        return "";
    }

    public function hasDockerComposeFile(string $path, OutputInterface $output) : bool
    {
        if (file_exists($path . "/docker-compose.yml")) {
            return true;
        }

        $output->writeln("<fg=red>Error:</>");
        $output->writeln("\tCan't find a suitable docker-compose file in this directory '$path'.");
        $output->writeln("\tIs this the right directory?");
        $output->writeln("\tSupported filenames: docker-compose.yml");

        return false;
    }

    public function generatePassword(int $length) : string
    {
        $bytes = openssl_random_pseudo_bytes($length);
        return bin2hex($bytes);
    }
}