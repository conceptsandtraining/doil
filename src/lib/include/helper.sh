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

function doil_get_hash() {
  if [ -z "$1" ]
  then
    echo "No name of instance given, aborting"
    exit
  fi

  DCPROC=$(docker ps | grep $1 -w)
  DCPROCHASH=${DCPROC:0:12}
  echo $DCPROCHASH
}

doil_get_data() {
  if [ -z "$1" ]
  then
    echo "No hash given, aborting"
    exit
  fi

  if [ -z "$2" ]
  then
    echo "No datatype given, aborting"
    exit
  fi

  case $2 in
    "ip")
      echo $(docker inspect --format "{{ .NetworkSettings.Networks.doil_proxy.IPAddress }}" $1)
      ;;
    "hostname")
      echo $(docker inspect -f '{{.Config.Hostname}}' $1)
      ;;
    "domainname")
      echo $(docker inspect -f '{{.Config.Domainname}}' $1)
      ;;
  esac
}

doil_get_command() {
  # get the command
  CMD=""
  oIFS=$IFS
  IFS=":"
  declare -a COMMANDS=(${1})
  if [ ! -z ${COMMANDS[1]} ]
  then
    CMD=${COMMANDS[1]}
  fi
  IFS=$oIFS
  unset $oIFS
  echo ${CMD}
}

doil_maybe_display_help() {
  SECTION=${1}
  COMMAND=${2}

  # check if command is just plain help
  # if we don't have any command we load the help
  if [ -z "${COMMAND}" ] \
    || [ "${COMMAND}" == "help" ] \
    || [ "${COMMAND}" == "--help" ] \
    || [ "${COMMAND}" == "-h" ]
  then
    eval "${DOILLIBPATH}/lib/${SECTION}/help.sh"
    exit
  fi
}

doil_eval_command() {
  SECTION=${1}
  COMMAND=${2}
  shift # past section
  shift # past command
  PARAMS=${@}

  # check if the command exists
  if [ ! -f "/usr/local/lib/doil/lib/${SECTION}/${COMMAND}/${COMMAND}.sh" ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tCan't find a suitable command."
    echo -e "\tUse \033[1mdoil ${SECTION}:help\033[0m for more information"
    exit 255
  fi

  eval "/usr/local/lib/doil/lib/${SECTION}/${COMMAND}/${COMMAND}.sh" ${PARAMS}
}

doil_send_log() {
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] ${1}"
}

doil_send_status() {
  echo -n "${1} ..."
}

doil_send_okay() {
  # color support
  GREEN='\033[0;32m'
  NC='\033[0m'

  printf " ${GREEN}ok${NC}\n"
}

doil_send_failed() {
  # color support
  RED='\033[0;31m'
  NC='\033[0m'

  printf " ${RED}failed${NC}\n"
}

doil_get_conf() {
  CONFIG=${1}
  VALUE=$(cat /etc/doil/doil.conf | grep ${CONFIG} | cut -d '=' -f 2-)
  echo ${VALUE}
}