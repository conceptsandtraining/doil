#!/bin/bash
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Stopping all running docker container"
docker stop $(docker ps -a -q)
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Finished"
