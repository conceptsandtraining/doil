#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2023 Daniel Weise (daniel.weise@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

# get the helper
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source ${SCRIPT_DIR}/checks.sh
source ${SCRIPT_DIR}/log.sh
source ${SCRIPT_DIR}/system.sh
source ${SCRIPT_DIR}/helper.sh

function delete() {
  ALL=$1

  if [ ! -z $ALL ]
  then
    doil_system_remove_all
  fi

  doil_system_remove_old_version
}

# sudo user check
doil_check_sudo
if [[ $? -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Please execute this script as sudo user!"
  exit
fi

if [ -z $1 ]
then
  echo "This will delete all doil related files on your system."
  read -r -p "Do you also want to delete all instances and images? [y/N] " RESPONSE
  case "$RESPONSE" in
      [yY][eE][sS]|[yY])
          delete all
          ;;
      *)
          delete
          ;;
  esac
elif [[ $1 == "-a" || $1 == "--all" ]]
then
  delete all
elif [[ $1 == "-n" || $1 == "--not-all" ]]
then
  delete
else
  echo "Usage: $0 [-a|--all] | [-n|--not-all]"
  echo "Please use the parameters carefully. There is no further security query."
fi