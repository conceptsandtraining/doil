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
    login|prune|start|stop|restart|reload|host)
      COMMAND="$key"
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/proxy/help.sh"
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
  echo -e "\tUse \033[1mdoil system:proxy --help\033[0m for more information"
  exit 255
fi

# login
if [[ ${COMMAND} == "login" ]]
then
  /usr/local/bin/doil system:proxy start

  docker exec -t -i doil_proxy bash
fi

# prune
if [[ ${COMMAND} == "prune" ]]
then
  doil_log_message "Pruning proxy server"

  /usr/local/bin/doil system:proxy start
  rm -rf /usr/local/lib/doil/server/proxy/conf/nginx/sites/*
  /usr/local/bin/doil system:proxy restart
  
  doil_log_message "Finished pruning proxy server"
fi

# start
if [[ ${COMMAND} == "start" ]]
then

  DCMAIN=$(docker ps | grep "doil_proxy")
  if [ -z "${DCMAIN}" ]
  then
    doil_log_message "Starting proxy server"
    # start service
    cd /usr/local/lib/doil/server/proxy || return
    docker-compose up -d --force-recreate
    doil_log_message "proxy server started"
  fi
fi

# stop
if [[ ${COMMAND} == "stop" ]]
then
  DCMAIN=$(docker ps | grep "doil_proxy")
  if [ ! -z "${DCMAIN}" ]
  then
    doil_log_message "Stopping proxy server"
    # stop service
    cd /usr/local/lib/doil/server/proxy || return
    docker-compose down
    doil_log_message "proxy server stopped"
  fi
fi

# restart
if [[ ${COMMAND} == "restart" ]]
then
  doil_log_message "Restarting proxy server"

  /usr/local/bin/doil system:proxy stop
  /usr/local/bin/doil system:proxy start

  doil_log_message "proxy server restarted"
fi

# reload
if [[ ${COMMAND} == "reload" ]]
then
  doil_log_message "Reloading proxy server"

  /usr/local/bin/doil system:proxy start
  docker exec -i doil_proxy bash -c "/etc/init.d/nginx reload"

  doil_log_message "proxy server reloaded"
fi

# host
if [[ ${COMMAND} == "host" ]]
then
  # sudo user check
  if [ "$EUID" -ne 0 ]
  then
    echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
    echo -e "\tPlease execute this script as sudo user!"
    exit
  fi
  
  doil_status_send_message "Changing host to ${HOST}"

  # doil conf
  CHANGE=$(sed -i "/host=/s/.*/host=${HOST}/" /etc/doil/doil.conf)

  # proxy conf
  CHANGE=$(sed -i "/server_name/s/.*/    server_name ${HOST};/" /usr/local/lib/doil/server/proxy/conf/nginx/local.conf)

  # host conf
  CHANGE=$(sed -i "/172.24.0.254/s/.*/172.24.0.254 ${HOST}/" /etc/hosts)

  /usr/local/bin/doil system:proxy restart

  doil_status_okay
fi