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

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    add|delete|list)
      COMMAND="$key"
      shift
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/user/help.sh"
      exit
      ;;
    *)    # unknown option
      THEUSER=${key}
      shift
      ;;
  esac
done

# sudo user check
if [ "$EUID" -ne 0 ]
then
  echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
  echo -e "\tPlease execute this script as sudo user!"
  exit
fi

# check command
if [ -z ${COMMAND} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tUnknown parameter!"
  echo -e "\tUse \033[1mdoil system:user --help\033[0m for more information"
  exit 255
fi

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

# add
if [[ ${COMMAND} == "add" ]]
then
  LINE=$(less "/etc/doil/user.conf" | grep ${THEUSER})
  if [ ! -z ${LINE} ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tUser ${THEUSER} already exist!"
    echo -e "\tUse \033[1mdoil system:user list\033[0m to see all user!"
    exit 255
  fi

  doil_send_status "Adding user ${THEUSER}"
  THEHOME=$(eval echo "~${THEUSER}")
  mkdir -p ${THEHOME}/.doil
  mkdir -p ${THEHOME}/.doil/config/
  touch ${THEHOME}/.doil/config/repositories.conf
  mkdir -p ${THEHOME}/.doil/repositories
  mkdir -p ${THEHOME}/.doil/instances
  chown -R ${THEUSER}:${THEUSER} "${THEHOME}/.doil"
  usermod -a -G doil ${THEUSER}
  echo "${THEUSER}">>"/etc/doil/user.conf"
  doil_send_okay

  exit
fi

# delete
if [[ ${COMMAND} == "delete" ]]
then
  LINE=$(less "/etc/doil/user.conf" | grep ${THEUSER})
  if [ -z ${LINE} ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tUser ${THEUSER} does not exist!"
    echo -e "\tUse \033[1mdoil system:user list\033[0m to see all user!"
    exit 255
  fi

  doil_send_status "Deleting user ${THEUSER}"
  THEHOME=$(eval echo "~${THEUSER}")
  rm -rf ${THEHOME}/.doil
  deluser ${THEUSER} doil>/dev/null
  LINE=$(sed -i "/${THEUSER}/d" "/etc/doil/user.conf")
  doil_send_okay

  exit
fi

# list
if [[ ${COMMAND} == "list" ]]
then
  echo "Currently registered users:"
  cat /etc/doil/user.conf
  exit
fi
