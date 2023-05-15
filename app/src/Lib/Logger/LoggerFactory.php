<?php declare(strict_types=1);

/* Copyright (c) 2022 - Daniel Weise <daniel.weise@concepts-and-training.de> - Extended GPL, see LICENSE */

namespace CaT\Doil\Lib\Logger;

use Monolog\Logger;
use Psr\Log\LoggerInterface;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\LineFormatter;

class LoggerFactory
{
    protected const DOIL_LOG_PATH = "/var/log/doil/doil.log";
    protected const SALT_LOG_PATH = "/var/log/doil/salt.log";

    public function getDoilLogger(string $channel) : LoggerInterface
    {
        $logger = new Logger($channel);
        $stream = new StreamHandler(self::DOIL_LOG_PATH, Logger::DEBUG, true, 0777);
        $form = new LineFormatter(null,null,true,false,true);
        $form->setJsonPrettyPrint(true);
        $stream->setFormatter($form);
        $logger->pushHandler($stream);
        return $logger;
    }

    public function getSaltLogger(string $channel) : LoggerInterface
    {
        $logger = new Logger($channel);
        $stream = new StreamHandler(self::SALT_LOG_PATH, Logger::DEBUG, true, 0777);
        $form = new LineFormatter(null,null,true,false,true);
        $form->setJsonPrettyPrint(true);
        $stream->setFormatter($form);
        $logger->pushHandler($stream);
        return $logger;
    }
}
