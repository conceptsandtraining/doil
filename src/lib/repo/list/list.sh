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
POSITIONAL=()
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/repo/list/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil repo:list --help\033[0m for more information"
      exit 255
      ;;
	esac
done

echo "Currently registered private repositories:"
while read line
do
  NAME="$(cut -d'=' -f1 <<<${line})"
  REPO="$(cut -d'=' -f2 <<<${line})"

  echo -e "\t${NAME} - ${REPO}"
done < "${HOME}/.doil/config/repositories.conf"

echo " "
echo "Currently registered global repositories:"
while read line
do
  NAME="$(cut -d'=' -f1 <<<${line})"
  REPO="$(cut -d'=' -f2 <<<${line})"

  echo -e "\t${NAME} - ${REPO}"
done < "/etc/doil/repositories.conf"