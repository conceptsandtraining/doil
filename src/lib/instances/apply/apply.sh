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

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

# check if command is just plain help
# if we don't have any command we load the help
POSITION=1
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/apply/help.sh"
      exit
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    -c|--context)
      CREATE_CONTEXT=TRUE
      shift # past argument
      ;;
    *)
      if (( ${POSITION} == 1 ))
      then
        INSTANCE=${key}
      fi
      if (( ${POSITION} == 2 ))
      then
        STATE=${key}
      fi
      POSITION=$((POSITION+1))
      shift
      ;;
  esac
done

if [[ -z "${INSTANCE}" ]]
then
  read -p "Name the instance you'd like to apply a state on: " INSTANCE
fi

if [[ ${GLOBAL} == TRUE ]]
then
  LINKPATH="/usr/local/share/doil/instances/${INSTANCE}"
else
  LINKPATH="${HOME}/.doil/instances/${INSTANCE}"
fi
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
STATEPATH="/usr/local/share/doil/stack/states/${STATE}"
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

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

if [[ -z ${CREATE_CONTEXT} ]]
then
  doil_send_log "Apply state ${STATE} to instance ${INSTANCE}"
fi

if [[ ${GLOBAL} == TRUE ]]
then
  SUFFIX="global"
  FLAG="--global"
else
  SUFFIX="local"
  FLAG=""
fi

/usr/local/bin/doil system:salt start --quiet
/usr/local/bin/doil up ${INSTANCE} --quiet ${FLAG}

# check key
SALTKEYS=$(docker exec -t -i saltmain bash -c "salt-key -L" | grep "${INSTANCE}.${SUFFIX}")
until [[ ! -z ${SALTKEYS} ]]
do
  sleep 5
  SALTKEYS=$(docker exec -t -i saltmain bash -c "salt-key -L" | grep "${INSTANCE}.${SUFFIX}")
done

if [[ ! -z ${CREATE_CONTEXT} ]]
then
  RND=$(( $RANDOM % 10 ))
  docker exec -i saltmain bash -c "salt '${INSTANCE}.${SUFFIX}' state.highstate saltenv=${STATE}" 2>&1 > /tmp/doil.${RND}.log
  CHECK=$(cat /tmp/doil.${RND}.log | grep "Failed:" | cut -d':' -f2)
  cat /tmp/doil.${RND}.log >> /var/log/doil.log
  rm /tmp/doil.${RND}.log
  exit
else
  docker exec -i saltmain bash -c "salt '${INSTANCE}.${SUFFIX}' state.highstate saltenv=${STATE}"
fi

if [[ -z ${CREATE_CONTEXT} ]]
then
  doil_send_log "Done"
fi