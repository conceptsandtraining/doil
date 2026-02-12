#!/bin/bash

/usr/bin/php {{ path }}cron/cron.php run-jobs {{ cronuser }} {{ instance }}
