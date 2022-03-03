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