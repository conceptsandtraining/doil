#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/ilias-tool-doil
#
#                    .-.
#                   / /
#                  / |
#    |\     ._ ,-""  `.
#    | |,,_/  7        ;
#  `;=     ,=(     ,  /
#   |`q  q  ` |    \_,|
#  .=; <> _ ; /  ,/'/ |
# ';|\,j_ \;=\ ,/   `-'
#     `--'_|\  )
#    ,' | /  ;'
#   (,,/ (,,/      Thanks to Concepts and Training for supporting doil

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    login|prune|start|stop|restart|reload)
      COMMAND="$key"
      shift
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/proxy/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil system:proxy --help\033[0m for more information"
      exit 255
      ;;
  esac
done

# check command
if [ -z ${COMMAND} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tUnknown parameter!"
  echo -e "\tUse \033[1mdoil system:proxy --help\033[0m for more information"
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
  doil system:proxy start --quiet

  docker exec -t -i doil_proxy bash
fi

# prune
if [[ ${COMMAND} == "prune" ]]
then
  doil_send_log "Pruning proxy server"

  doil system:proxy start --quiet
  rm -rf /usr/local/lib/doil/tpl/proxy/conf/sites/*
  doil system:proxy restart --quiet
  
  doil_send_log "Finished pruning proxy server"
fi

# start
if [[ ${COMMAND} == "start" ]]
then

  DCMAIN=$(docker ps | grep "doil_proxy")
  if [ -z "${DCMAIN}" ]
  then
    doil_send_log "Starting proxy server"
    # start service
    cd /usr/local/lib/doil/tpl/proxy || return
    docker-compose up -d --force-recreate
    doil_send_log "proxy server started"
  fi
fi

# stop
if [[ ${COMMAND} == "stop" ]]
then
  DCMAIN=$(docker ps | grep "doil_proxy")
  if [ ! -z "${DCMAIN}" ]
  then
    doil_send_log "Stopping proxy server"
    # stop service
    cd /usr/local/lib/doil/tpl/proxy || return
    docker-compose down
    doil_send_log "proxy server stopped"
  fi
fi

# restart
if [[ ${COMMAND} == "restart" ]]
then
  doil_send_log "Restarting proxy server"

  doil system:proxy stop --quiet
  doil system:proxy start --quiet

  doil_send_log "proxy server restarted"
fi

# reload
if [[ ${COMMAND} == "reload" ]]
then
  doil_send_log "Reloading proxy server"

  doil system:proxy start --quiet
  docker exec -ti doil_proxy bash -c "/etc/init.d/nginx reload"

  doil_send_log "proxy server reloaded"
fi
