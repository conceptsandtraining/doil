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

# sudo user check
if [ "$EUID" -ne 0 ]
then
  echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
  echo -e "\tPlease execute this script as sudo user!"
  exit
fi

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
POSITIONAL=()
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/system/deinstall/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil system:deinstall --help\033[0m for more information"
      exit 255
      ;;
	esac
done

read -p "Please confirm that you want to deinstall doil [yN]: " CONFIRM
if [[ ${CONFIRM} == "y" ]]
then
  if [ -f "/usr/local/bin/doil" ]
  then
    rm /usr/local/bin/doil
  fi
  if [ -d "/usr/local/lib/doil" ]
  then
    rm -rf /usr/local/lib/doil
  fi
  rm -rf /var/log/doil.log
  rm -rf "${HOME}/.doil"
fi