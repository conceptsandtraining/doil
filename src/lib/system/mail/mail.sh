#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/log.sh
source /usr/local/lib/doil/lib/include/helper.sh

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    login|start|stop|restart)
      COMMAND="$key"
      shift
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/mail/help.sh"
      exit
      ;;
    *)    # unknown option
      HOST=${1}
      shift
      ;;
  esac
done

# check command
if [ -z ${COMMAND} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tUnknown parameter!"
  echo -e "\tUse \033[1mdoil system:mail --help\033[0m for more information"
  exit 255
fi

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

# login
if [[ ${COMMAND} == "login" ]]
then
  doil system:mail start --quiet

  docker exec -t -i doil_postfix bash
fi

# start
if [[ ${COMMAND} == "start" ]]
then

  DCMAIN=$(docker ps | grep "doil_postfix")
  if [ -z "${DCMAIN}" ]
  then
    doil_send_log "Starting mail server"
    # start service
    cd /usr/local/lib/doil/server/mail || return
    docker-compose up -d --force-recreate
    doil_send_log "mail server started"
  fi
fi

# stop
if [[ ${COMMAND} == "stop" ]]
then
  DCMAIN=$(docker ps | grep "doil_postfix")
  if [ ! -z "${DCMAIN}" ]
  then
    doil_send_log "Stopping mail server"
    # stop service
    cd /usr/local/lib/doil/server/mail || return
    docker-compose down
    doil_send_log "mail server stopped"
  fi
fi

# restart
if [[ ${COMMAND} == "restart" ]]
then
  doil_send_log "Restarting mail server"

  doil system:mail stop --quiet
  doil system:mail start --quiet

  doil_send_log "mail server restarted"
fi