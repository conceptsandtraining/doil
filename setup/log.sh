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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/colors.sh

doil_status_send_message() {
  exec >>/dev/tty 2>&1
  echo -n "${1} ..."

  RESET=${2}
  if [[ ! -z ${RESET} ]]
  then
    exec >> "${RESET}" 2>&1
  fi
}

doil_status_send_message_nl() {
  exec >>/dev/tty 2>&1
  echo "${1} ..."

  RESET=${2}
  if [[ ! -z ${RESET} ]]
  then
    exec >> "${RESET}" 2>&1
  fi
}

doil_status_send_error() {
  echo -e "\033[1m${1}:\033[0m"
  echo -e "\t${2}"
}

doil_status_okay() {
  exec >>/dev/tty 2>&1
  printf " ${GREEN}done${NC}\n"

  RESET=${2}
  if [[ ! -z ${RESET} ]]
  then
    exec >> "${RESET}" 2>&1
  fi
}

doil_status_failed() {
  exec >>/dev/tty 2>&1
  printf " ${RED}failed${NC}\n"

  RESET=${2}
  if [[ ! -z ${RESET} ]]
  then
    exec >> "${RESET}" 2>&1
  fi
}

doil_log_message() {
  MESSAGE=${1}
  TYPE=${2}

  if [[ -z ${TYPE} ]]
  then
    TYPE="info"
  fi
  MSG=$(doil_log_format_message "${MESSAGE}" ${TYPE})
  echo "${MSG}" >> /var/log/doil/info.log
}

doil_log_error_message() {
  MESSAGE=${1}
  TYPE="error"
  MSG=$(doil_log_format_message "${MESSAGE}" ${TYPE})
  echo "${MSG}" >> /var/log/doil/error.log
}

doil_log_instance_message() {
  INSTANCE=${1}
  MESSAGE=${2}
  TYPE=${3}

  if [[ -z ${TYPE} ]]
  then
    TYPE="info"
  fi
  MSG=$(doil_log_format_message "${MESSAGE}" ${TYPE})


}

doil_log_format_message() {
  MESSAGE=${1}
  TYPE=${2}
  NOW=$(date +'%Y-%m-%dT%I:%M:%S')
  echo "${TYPE} - ${NOW} : ${MESSAGE}"
}