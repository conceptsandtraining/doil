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
source /usr/local/lib/doil/lib/include/helper.sh

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/up/help.sh"
      exit
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    *)    # start the instance
      INSTANCE=$1
      shift
      ;;
	esac
done

if [ -z "${INSTANCE}" ]
then
  # if the instance is empty we are working with the current directory

  # check if docker-compose.yml exists and bail if not
  if [ ! -f "docker-compose.yml" ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tCan't find a suitable configuration file in this directory"
    echo -e "\tAre you in the right directory?"
    echo -e "\n\tSupported filenames: docker-compose.yml"

    exit
  fi

  # Pipe output to null if needed
  if [[ ${QUIET} == TRUE ]]
  then
    exec >>/var/log/doil.log 2>&1
  fi

  # set instance
  INSTANCE=${PWD##*/}

  if [[ ${GLOBAL} == TRUE ]]
  then
    SUFFIX="global"
    FLAG="--global"
  else
    SUFFIX="local"
    FLAG=""
  fi

  # check if we are running
  DCMINION=$(docker ps | grep ${INSTANCE}_${SUFFIX} -w)
  if [ ! -z "${DCMINION}" ]
  then
    exit
  fi

  doil_send_log "Starting instance"

  # check saltmain
  doil system:salt start --quiet

  # check proxy server
  doil system:proxy start --quiet

  # check maik server
  doil system:mail start --quiet

  # Start the container
  docker-compose up -d

  # start cron service
  docker exec -i ${INSTANCE}_${SUFFIX} bash -c "service cron status" 2>&1 > /dev/null
  docker exec -i ${INSTANCE}_${SUFFIX} bash -c "service cron start" 2>&1 > /dev/null
  
  # remove the current ip from the host file and add the new one
  DCHASH=$(doil_get_hash ${INSTANCE}_${SUFFIX})
  DCIP=$(doil_get_data $DCHASH "ip")

  if [ -f "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf" ]
  then
    rm "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
  fi
  cp "/usr/local/lib/doil/server/proxy/service-config.tpl" "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
  if [ ${HOST} == "linux" ]; then
    sed -i "s/%IP%/${DCIP}/g" "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
    sed -i "s/%DOMAIN%/${INSTANCE}/g" "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
  elif [ ${HOST} == "mac" ]; then
    sed -i "" "s/%IP%/${DCIP}/g" "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
    sed -i "" "s/%DOMAIN%/${INSTANCE}/g" "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
  fi
  
  doil system:proxy reload --quiet

  doil_send_log "Instance started. Navigate to http://doil/${INSTANCE}"
else
  if [[ ${GLOBAL} == TRUE ]]
  then
    LINKNAME="/usr/local/share/doil/instances/${INSTANCE}"
    FLAG="--global"
  else
    LINKNAME="${HOME}/.doil/instances/${INSTANCE}"
    FLAG=""
  fi
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    cd ${TARGET}
    eval "doil instances:up ${FLAG}"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
    exit
  fi
fi