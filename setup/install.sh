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

source ${SCRIPT_DIR}/checks.sh
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

# sudo user check
doil_check_ports
if [[ $? -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Please ensure that port 80 and port 443 are available and free!"
  exit
fi

# sudo user in docker group
doil_check_user_in_docker_group
CHECK_DOCKER_GROUP=$?
if [[ ${CHECK_DOCKER_GROUP} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Please ensure that $SUDO_USER is in the docker group!"
  exit
fi

# sudo user in docker group
doil_check_root_has_docker_compose
CHECK_DOCKER_COMPOSE=$?
if [[ ${CHECK_DOCKER_COMPOSE} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Please ensure that root has access to docker-compose!"
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

# php version check
doil_check_php_version
CHECK_PHP=$?
if [[ ${CHECK_PHP} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Your php version is not supported!"
  exit
fi

# php module dom check
doil_check_php_module_dom
CHECK_PHP_MODULE_DOM=$?
if [[ ${CHECK_PHP_MODULE_DOM} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Missing php module dom!"
  exit
fi

# php module zip check
doil_check_php_module_zip
CHECK_PHP_MODULE_ZIP=$?
if [[ ${CHECK_PHP_MODULE_ZIP} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Missing php module zip!"
  exit
fi

# composer installed check
doil_check_composer
COMPOSER=$?
if [[ ${COMPOSER} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Missing composer!"
  exit
fi

# git installed check
doil_check_git
GIT=$?
if [[ ${GIT} -ne 0 ]]
then
  doil_status_failed
  doil_status_send_error "REQUIREMENT ERROR" "Missing git!"
  exit
fi

# status for check requirements
doil_status_okay

doil_status_send_message_nl "Set host variable"
doil_set_host
CHECK=$?
if [[ ${CHECK} -ne 0 ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

doil_status_send_message "Creating log file"
doil_system_setup_log
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

doil_status_send_message "Run composer"
doil_system_run_composer
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

if [[ "${HOST}" == "doil" ]]
then
  doil_status_send_message "Setting up IP"
  doil_system_setup_ip
  CHECK=$?
  if [[ ${CHECK} -ne 0 ]]
  then
    doil_status_failed
    exit
  fi
  doil_status_okay
fi

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

if [[ -z ${GHRUN} ]]
then
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
