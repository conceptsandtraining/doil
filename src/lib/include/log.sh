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
  echo -n "${1} ..."
}

doil_status_send_error() {
  echo -e "\033[1m${1}:\033[0m"
  echo -e "\t${2}"
}

doil_status_okay() {
  printf " ${GREEN}ok${NC}\n"
}

doil_status_failed() {
  printf " ${RED}failed${NC}\n"
}