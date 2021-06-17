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

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
POSITIONAL=()
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    login|restart|prune)
      COMMAND="$key"
      shift # past argument
      shift # past value
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
  # check saltmain
  DCMAIN=$(docker ps | grep "saltmain")
  if [ -z "${DCMAIN}" ]
  then
    CWD=$(pwd)
    cd /usr/local/lib/doil/tpl/main || return
    docker-compose up -d
    cd "${CWD}" || return
  fi

  docker exec -t -i saltmain bash
  exit
fi

# prune
if [[ ${COMMAND} == "prune" ]]
then
  # check saltmain
  DCMAIN=$(docker ps | grep "saltmain")
  if [ -z "${DCMAIN}" ]
  then
    CWD=$(pwd)
    cd /usr/local/lib/doil/tpl/main || return
    docker-compose up -d
    cd "${CWD}" || return
  fi

  docker exec -ti saltmain bash -c 'echo "y" | salt-key -D'
  exit
fi

# restart
if [[ ${COMMAND} == "restart" ]]
then
  # restart service
  cd /usr/local/lib/doil/tpl/main || return
  docker-compose down
  docker-compose up -d
fi