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

# sudo user check
if [ "$EUID" -ne 0 ]
then
  echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
  echo -e "\tPlease execute this script as sudo user!"
  exit
fi

read -p "Please confirm that you want to deinstall doil [yN]: " CONFIRM
if [[ ${CONFIRM} == "y" ]]
then

  doil_send_status "Removing proxy server"
  doil system:proxy stop --quiet
  docker image rm doil_proxy > /dev/null
  docker volume rm proxy_persistent > /dev/null
  doil_send_okay

  doil_send_status "Removing salt server"
  doil system:salt stop --quiet
  docker image rm saltmain > /dev/null
  docker volume rm salt_persistent > /dev/null
  doil_send_okay

  doil_send_status "Deleting registered users"
  for THEUSER in cat /etc/doil/user.conf
  do
    doil system:user delete ${THEUSER} --quiet
  done
  doil_send_okay

  doil_send_status "Deleting group doil"
  groupdel doil
  doil_send_okay

  doil_send_status "Deleting log"
  rm -rf /var/log/doil.log
  doil_send_okay

  doil_send_status "Removing doil"
  rm -rf /etc/doil/
  rm -rf /usr/local/lib/doil
  rm -rf /usr/local/share/doil
  rm -rf /usr/local/bin/doil
  doil_send_okay

  echo "Doil successfully deleted"
fi