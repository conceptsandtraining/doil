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
    -r|--repo)
      REPOSITORY="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/salt/set/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil salt:set --help\033[0m for more information"
      exit 255
      ;;
	esac
done

# check repo
if [[ -z "${NAME}" ]]
then
  read -p "URL of the repository: " REPOSITORY
fi
if [ -z ${REPOSITORY} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tParameter --repo not set!"
  echo -e "\tUse \033[1mdoil salt:set --help\033[0m for more information"
  exit 255
fi

$(echo "${REPOSITORY}" > "${HOME}/.doil/config/saltstack")
if [[ ! -d /usr/local/lib/doil/tpl/main/stack ]]
then
  mv /usr/local/lib/doil/tpl/stack /usr/local/lib/doil/tpl/main/stack
fi
git clone ${REPOSITORY} /usr/local/lib/doil/tpl/stack
echo "saltstack ${REPOSITORY} set."