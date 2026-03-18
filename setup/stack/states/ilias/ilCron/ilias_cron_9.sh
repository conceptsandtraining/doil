#!/bin/bash

/usr/bin/php {{ path }}/cron.php run-jobs {{ cronuser }} {{ instance }}
