#!/bin/bash

/usr/bin/php {{ path }}cron/cron.php {{ cronuser }} {{ passwd }} {{ instance }}
