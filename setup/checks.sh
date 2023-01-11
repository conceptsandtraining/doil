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

# get additional helper
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/helper.sh

# checks if the current user is a sudo user
#
# return 255 if user is not sudo user
# return 0 if user is sudo user
function doil_check_sudo() {
	if [[ "$EUID" -ne 0 ]]
	then
	  return 255
	fi
  return 0
}

# checks if the the ports 80 and 443 are free
#
# return 255 if one port isn't free
# return 0 if both ports are free
function doil_check_ports() {
  lsof -i:80 -P -n | grep LISTEN > /dev/null 2>&1
  P80=$?
  lsof -i:443 -P -n | grep LISTEN > /dev/null 2>&1
  P443=$?
	if [[ "${P80}" -eq 1 && "${P443}" -eq 1 ]]
	then
	  return 0
	fi
  return 255
}

# checks if user is in docker group
#
# return 255 if user is not in docker group
# return 0 if user is in docker group
function doil_check_user_in_docker_group() {
  id -nG $SUDO_USER | grep -qw 'docker'
  if [[ $? -ne 0 ]]
    then
      return 255
    fi
  return 0
}

# checks if user is in doil group
#
# return 255 if user is not in doil group
# return 0 if user is in doil group
function doil_check_user_in_doil_group() {
  id -nG $SUDO_USER | grep -qw 'doil'
  if [[ $? -ne 0 ]]
    then
      return 255
    fi
  return 0
}

# checks if root has docker-compose
#
# return 255 if root has no docker-compose
# return 0 if root has docker-compose
function doil_check_root_has_docker_compose() {
  DOCKERCOMPOSE=$(docker-compose -v | grep version | wc -l)
  if [[ ${DOCKERCOMPOSE} -ne 1 ]]
    then
      return 255
    fi
  return 0
}

# checks if the host system is supported
#
# return 255 if system is not supported
# return 0 if system is supported
function doil_check_host() {
  # check the OS
  OPS=""
  case "$(uname -s)" in
    Darwin)
      return 0
      ;;
    Linux)
      return 0
      ;;
    *)
      return 255
      ;;
  esac
  return 0
}

# checks if the php version is supported
#
# return 255 if php is not supported
# return 0 if php is supported
function doil_check_php_version() {
  PHP=$(php --ini | grep Loaded | cut -d' ' -f12 | cut -d/ -f4)
  case "${PHP}" in
    "8.2")
      return 0
      ;;
    "8.1")
      return 0
      ;;
    "8.0")
      return 0
      ;;
    "7.4")
      return 0
      ;;
    *)
      return 255
      ;;
    esac
  return 0
}

# checks if the php module dom is supported
#
# return 255 if module is not supported
# return 0 if module is supported
function doil_check_php_module_dom() {
  DOM=$(php --ini | grep dom | wc -l)
  if [[ ${DOM} -ne 0 ]]
  then
    return 0
  fi
  return 255
}

# checks if the php module zip is supported
#
# return 255 if module is not supported
# return 0 if module is supported
function doil_check_php_module_zip() {
  DOM=$(php --ini | grep zip | wc -l)
  if [[ ${DOM} -ne 0 ]]
  then
    return 0
  fi
  return 255
}

# checks if the composer is supported
#
# return 255 if composer is not supported
# return 0 if composer is supported
function doil_check_composer() {
  COMPOSER=$(su $SUDO_USER -c 'composer -n | wc -l')
  if [[ ${COMPOSER} -ne 0 ]]
    then
      return 0
    fi
  return 255
}

# checks if the git is supported
#
# return 255 if git is not supported
# return 0 if git is supported
function doil_check_git() {
  GIT=$(su $SUDO_USER -c 'git --version | wc -l')
  if [[ ${GIT} -ne 0 ]]
    then
      return 0
    fi
  return 255
}

# checks if the installed docker version is
# supported
#
# return 255 if version is not supported
# return 0 if version is supported
function doil_check_docker_version() {
  DOCKER_VERSION=$(docker --version | tail -n 1 | cut -d " " -f 3 | cut -c 1-5)
  doil_test_version_compare ${DOCKER_VERSION} "19.02" ">"
  return $?
}

# checks if .ssh folder exists
#
# return 255 if .shh is not exists
# return 0 if .ssh is exists
function doil_check_ssh() {
  if [[ -d /home/$SUDO_USER/.ssh ]]
    then
      return 0
    fi

  return 255
}