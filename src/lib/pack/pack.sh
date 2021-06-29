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

# check if command is just plain help
# if we don't have any command we load the help
if [ -z "${CMD}" ] \
	|| [ "${CMD}" == "help" ] \
  || [ "${CMD}" == "--help" ] \
  || [ "${CMD}" == "-h" ]
then
  eval "/usr/local/lib/doil/lib/pack/help.sh"
  exit
fi

# check if the command exists
if [ ! -f "/usr/local/lib/doil/lib/pack/${CMD}/${CMD}.sh" ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tCan't find a suitable command."
  echo -e "\tUse \033[1mdoil pack:help\033[0m for more information"
  exit 255
fi

eval "/usr/local/lib/doil/lib/pack/${CMD}/${CMD}.sh" $@