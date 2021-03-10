#!/bin/bash

il_log=/var/ilias/logs/

if [ ! -d ${il_log} ]; then
  echo "ILIAS logpath could not be found"
  exit 1
fi

if [[ ${il_log} = *log* ]]; then
  echo "Using ${il_log}"
else
  echo "${il_log} doesn't look like a logfile directory (must contain log)"
  exit 2
fi

find ${il_log} -mtime -1 -print > /tmp/il_newlogs.txt

sed -i "s|${il_log}||" /tmp/il_newlogs.txt

filesize=$(stat -c%s /tmp/il_newlogs.txt)

# TODO make this optional
#if [ ${filesize} != 1 ]; then
#  cat /tmp/il_newlogs.txt | mail -s "New ILIAS error.logs" root@cat06.de
#else
#  echo "No new logfiles found"
#fi

find ${il_log} -maxdepth 1 -mtime 30 -delete
