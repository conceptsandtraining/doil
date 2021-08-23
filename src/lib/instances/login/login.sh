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
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/login/help.sh"
      exit
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    *)    # sets the instance
      INSTANCE=$1
      shift
      ;;
	esac
done

# set the instance to work with
if [ -z "$INSTANCE" ]
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

  if [[ ${GLOBAL} == TRUE ]]
  then
    SUFFIX="global"
    FLAG="--global"
  else
    SUFFIX="local"
    FLAG=""
  fi

  # set instance
  INSTANCE=${PWD##*/}

  # start if not done
  doil up ${INSTANCE} --quiet ${FLAG}
  
  # login
  docker exec -ti ${INSTANCE} bash
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
    eval "doil login ${FLAG}"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
  fi
fi
