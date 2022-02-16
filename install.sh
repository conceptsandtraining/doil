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
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/src/lib/include/checks.sh
source ${SCRIPT_DIR}/log.sh
source ${SCRIPT_DIR}/system.sh

# check requirements
doil_status_send_message "Checking requirements"

# sudo user check
doil_check_sudo
CHECK_SUDO=$?
if [[ ${CHECK_SUDO} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Please execute this script as sudo user!"
  exit
fi

# host check
doil_check_host
CHECK_HOST=$?
if [[ ${CHECK_HOST} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Your operating system is not supported!"
  exit
fi

# docker version check
doil_check_docker_version
CHECK_DOCKER=$?
if [[ ${CHECK_DOCKER} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Your docker version is not supported!"
  exit
fi

# status for check requirements
doil_status_okay

doil_status_send_message "Creating log file"
doil_system_touch_log_file
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Adding group"
doil_system_add_group
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay


doil_status_send_message "Creating mandatory folder"
doil_system_create_folder
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Copy doil system"
doil_system_copy_doil
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Setting up basic configuration"
doil_system_setup_config
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Setting up IP"
doil_system_setup_ip
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Setting up access rights"
doil_system_setup_access
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Configuring user specific data"
doil_system_setup_userconfig
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

# start proxy server
doil_status_send_message "Installing proxy server"
doil system:proxy start --quiet
doil_status_okay

# start salt server
doil_status_send_message "Installing salt server"
doil system:salt start --quiet
doil_status_okay

#################
# Everything done
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Everything done"
