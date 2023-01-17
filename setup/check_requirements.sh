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

function check_requirements() {
  UPDATE=${1}

  # check requirements
  doil_status_send_message "Checking requirements"

  # sudo user check
  doil_check_sudo
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Please execute this script as sudo user!"
    exit
  fi

  # check for free 80/443 ports
  if [[ ${UPDATE} == "" ]]
  then
    doil_check_ports
    if [[ $? -ne 0 ]]
    then
      doil_status_failed
      doil_status_send_error "REQUIREMENT ERROR" "Please ensure that port 80 and port 443 are available and free! Maybe an Apache webserver is running?"
      exit
    fi
  fi

  # sudo user in docker group
  doil_check_user_in_docker_group
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Please ensure that $SUDO_USER is in the docker group!"
    exit
  fi

  # sudo user in docker group
  doil_check_root_has_docker_compose
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Please ensure that root has access to docker-compose!"
    exit
  fi

  # host check
  doil_check_host
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Your operating system is not supported!"
    exit
  fi

  # docker version check
  doil_check_docker_version
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Your docker version is not supported!"
    exit
  fi

  # php version check
  doil_check_php_version
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Your php version is not supported!"
    exit
  fi

  # php module dom check
  doil_check_php_module_dom
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Missing php module dom!"
    exit
  fi

  # php module zip check
  doil_check_php_module_zip
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Missing php module zip!"
    exit
  fi

  # composer installed check
  doil_check_composer
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Missing composer!"
    exit
  fi

  # git installed check
  doil_check_git
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    doil_status_send_error "REQUIREMENT ERROR" "Missing git!"
    exit
  fi

  # status for check requirements
  doil_status_okay
}