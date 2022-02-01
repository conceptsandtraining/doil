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

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/repo/delete/help.sh"
      exit
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past this flag
      ;;
    -q|--quiet)
      QUIET=YES
      shift # past argument
      ;;
    *)    # unknown option
      NAME=$1
      shift
      ;;
	esac
done

# check parameter
if [ -z ${NAME} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tParameter --name not set!"
  echo -e "\tUse \033[1mdoil repo:delete --help\033[0m for more information"
  exit 255
fi

# check if repo exists
if [[ ${GLOBAL} == "TRUE" ]]
then
  LINE=$(sed -n -e "/^${NAME}=/p" "/etc/doil/repositories.conf")
else
  LINE=$(sed -n -e "/^${NAME}=/p" "${HOME}/.doil/config/repositories.conf")
fi

if [ -z ${LINE} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tRepository ${NAME} does not exist!"
  echo -e "\tUse \033[1mdoil repo:list\033[0m to see all repositories!"
  exit 255
fi

if [[ ${GLOBAL} == "TRUE" ]]
then
  LINE=$(sed -i "/${NAME}=/d" "/etc/doil/repositories.conf")
  rm -rf "/usr/local/share/doil/repositories/${NAME}"
else
  LINE=$(sed -i "/${NAME}=/d" "${HOME}/.doil/config/repositories.conf")
  rm -rf "${HOME}/.doil/repositories/${NAME}"
fi

if [ -z ${QUIET} ]
then
  echo "Repository ${NAME} deleted."
fi