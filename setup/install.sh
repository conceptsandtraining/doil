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
source ${SCRIPT_DIR}/check_requirements.sh
source ${SCRIPT_DIR}/updates/update.sh
source ${SCRIPT_DIR}/helper.sh
source ${SCRIPT_DIR}/env.sh
source ${SCRIPT_DIR}/colors.sh

check_requirements

doil_status_send_message "Adding group 'doil'"
doil_system_add_group
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Adding user to group 'doil'"
doil_system_add_user_to_doil_group
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Checking if user is in 'doil' group"
doil_check_user_in_doil_group
if [[ $? -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "INFO" "Please log out and log in to the host system again to ensure\n\tthat your user belongs to the doil group and start install again."
  exit
fi
doil_status_okay

doil_status_send_message "Creating log file"
doil_system_setup_log
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Creating mandatory folder"
doil_system_create_folder
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Copy doil system"
doil_system_copy_doil
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Setting up basic configuration"
doil_system_setup_config
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay


doil_status_send_message "Setting up IP"
doil_system_setup_ip
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Setting up access rights"
doil_system_setup_access
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Configuring user specific data"
doil_system_setup_userconfig
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Add safe git dir for root"
doil_system_add_safe_git_dir
if [[ $? -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Delete potential composer lock file"
doil_system_delete_potential_composer_lock
doil_status_okay

if [[ -z ${GHRUN} ]]
then
  # start salt server
  doil_status_send_message "Building doil php image"
  doil_system_build_php_image
  doil_status_okay

  # start salt server
  doil_status_send_message "Installing salt server"
  doil_system_install_saltserver
  doil_status_okay

  # start proxy server
  doil_status_send_message "Installing proxy server"
  doil_system_install_proxyserver
  doil_status_okay

  # start mail server
  doil_status_send_message "Installing mail server"
  doil_system_install_mailserver
  doil_status_okay
fi

#################
# Everything done
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Everything done"