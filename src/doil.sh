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
#
# Last revised 2021-xx-xx

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

# check the most basic thing
if [ -z ${1:+x} ]
then
  eval "/usr/local/lib/doil/lib/system/help.sh"
  exit
fi

# get the first argument before the ":" to set the section
oIFS=$IFS
IFS=":"
declare -a COMMANDS=(${1})
SECTION=${COMMANDS[0]}
IFS=$oIFS
unset $oIFS

# check if section is just plain help
# if we don't have any command we load the help
if [ -z "${SECTION}" ] \
	|| [ "${SECTION}" == "help" ] \
  || [ "${SECTION}" == "--help" ] \
  || [ "${SECTION}" == "-h" ]
then
  eval "/usr/local/lib/doil/lib/system/help.sh"
  exit
fi

# check if the section exists
if [ ! -d "/usr/local/lib/doil/lib/${SECTION}" ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tCan't find a suitable command."
  echo -e "\tUse \033[1mdoil help\033[0m for more information"
  exit 255
fi

eval "/usr/local/lib/doil/lib/${SECTION}/${SECTION}.sh" $@