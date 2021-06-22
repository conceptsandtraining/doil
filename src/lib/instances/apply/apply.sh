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

# we need to move the pointer two positions
shift
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -i|--instance)
      INSTANCE="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--state)
      STATE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/apply/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil instances:apply --help\033[0m for more information"
      exit 255
      ;;
	esac
done

if [[ -z "${INSTANCE}" ]]
then
  read -p "Name the instance you'd like to apply a state on: " INSTANCE
fi
LINKPATH="${HOME}/.doil/${INSTANCE}"
if [[ -z "${INSTANCE}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tName of the instance cannot be empty!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
elif [[ ${INSTANCE} == *['!'@#\$%^\&\(\)*_+]* ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInvalid characters! Only letters and numbers are allowed!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
elif [[ ! -h "${LINKPATH}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe instance ${INSTANCE} does not exist!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
fi

if [[ -z "${STATE}" ]]
then
  read -p "Name the state you want to apply: " STATE
fi
STATEPATH="/usr/local/lib/doil/tpl/stack/states/${STATE}"
if [[ -z "${STATE}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tName of the instance cannot be empty!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
elif [[ ${STATE} == *['!'@#\$%^\&\(\)*_+]* ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInvalid characters! Only letters and numbers are allowed!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
elif [[ ! -d "${STATEPATH}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe state ${STATE} does not exist!"
  echo -e "\tsee \033[1mdoil instances:apply --help\033[0m for more information"
  exit
fi

NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply state ${STATE} to instance ${INSTANCE}"

# start minion
doil up ${INSTANCE}

# check key
SALTKEYS=$(docker exec -t -i saltmain bash -c "salt-key -L" | grep "${INSTANCE}.local")
until [[ ! -z ${SALTKEYS} ]]
do
  echo "Key not ready yet ... waiting"
  sleep 5
  SALTKEYS=$(docker exec -t -i saltmain bash -c "salt-key -L" | grep "${INSTANCE}.local")
done
echo "Key ready"

echo "Apply state"
docker exec -ti saltmain bash -c "salt '${INSTANCE}.local' state.highstate saltenv=${STATE} --state-output=terse"

NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Done"