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
    login|prune|start|stop|restart|states)
      COMMAND="$key"
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/salt/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil system:salt --help\033[0m for more information"
      exit 255
      ;;
  esac
done

# check command
if [ -z ${COMMAND} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tUnknown parameter!"
  echo -e "\tUse \033[1mdoil system:salt --help\033[0m for more information"
  exit 255
fi

# login
if [[ ${COMMAND} == "login" ]]
then
  /usr/local/bin/doil system:salt start

  docker exec -t -i doil_saltmain bash
  exit
fi

# prune
if [[ ${COMMAND} == "prune" ]]
then
  doil_log_message "Pruning main salt server"

  /usr/local/bin/doil system:salt start

  docker exec -i doil_saltmain bash -c 'echo "y" | salt-key -D'
  
  doil_log_message "Finished pruning main salt server"
fi

# start
if [[ ${COMMAND} == "start" ]]
then
  DCMAIN=$(docker ps | grep "doil_saltmain")
  if [ -z "${DCMAIN}" ]
  then
    doil_log_message "Starting main salt server"
    # start service
    cd //usr/local/lib/doil/server/salt || return
    docker-compose up -d --force-recreate
    doil_log_message "Main salt server started"
  fi
fi

# stop
if [[ ${COMMAND} == "stop" ]]
then
  DCMAIN=$(docker ps | grep "doil_saltmain")
  if [ ! -z "${DCMAIN}" ]
  then
    doil_log_message "Stopping main salt server"
    # stop service
    cd //usr/local/lib/doil/server/salt || return
    docker-compose down
    doil_log_message "Main salt server stopped"
  fi
fi

# restart
if [[ ${COMMAND} == "restart" ]]
then
  doil_log_message "Restarting main salt server"

  /usr/local/bin/doil system:salt stop
  /usr/local/bin/doil system:salt start

  doil_log_message "Main salt server restarted"
fi

# states
if [[ ${COMMAND} == "states" ]]
then
  echo "Currently available states to apply:"

  ls -1 /usr/local/share/doil/stack/states
fi