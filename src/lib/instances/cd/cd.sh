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
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/cd/help.sh"
      exit
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    *)    # set the instance
      INSTANCE=$1
      shift
      ;;
	esac
done

if [ ! -z "${INSTANCE}" ]
then
  if [[ ${GLOBAL} == TRUE ]]
  then
    LINKNAME="/usr/local/share/doil/instances/${INSTANCE}"
  else
    LINKNAME="${HOME}/.doil/instances/${INSTANCE}"
  fi
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    builtin cd ${TARGET} 2> /var/log/doil.log
    exec $SHELL
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
    exit
  fi
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tPlease specify an instance in order to navigate there."
  exit
fi