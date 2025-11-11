#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2025 Daniel Weise (daniel.weise@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

function doil_check_doil_artifacts() {
  if [[ -d /etc/doil || -d /usr/local/lib/doil || -d /usr/local/share/doil || -d /home/$SUDO_USER/.doil || -f /usr/local/bin/doil || -d /var/log/doil ]]
  then
    return 255
  fi
  return 0
}

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

# checks if user is in doil group
#
# return 255 if user is not in doil group
# return 0 if user is in doil group
function doil_check_user_in_doil_group() {
  id -nG $SUDO_USER | grep -qw 'doil' > /dev/null 2>&1
  if [[ $? -ne 0 ]]
    then
      return 255
    fi
  return 0
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

# checks if root has docker compose access
#
# return 255 if root has no docker compose access
# return 0 if root has docker compose access
function doil_check_root_has_docker_compose() {
  DOCKERCOMPOSE=$(docker compose version | grep version | wc -l)
  if [[ ${DOCKERCOMPOSE} -ne 1 ]]
    then
      return 255
    fi
  return 0
}

# checks if root has docker buildx access
#
# return 255 if root has no docker buildx access
# return 0 if root has docker buildx access
function doil_check_root_has_docker_buildx() {
  DOCKERBUILDX=$(docker buildx version | grep "buildx" | wc -l)
  if [[ ${DOCKERBUILDX} -ne 1 ]]
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

doil_version_compare() {
  if [[ $1 == $2 ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]
    then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]}))
    then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]}))
    then
      return 2
    fi
  done
  return 0
}

doil_test_version_compare() {
  doil_version_compare $1 $2
  case $? in
    0) op='=';;
    1) op='>';;
    2) op='<';;
  esac
  if [[ $op != $3 ]]
  then
    return 255
  fi
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
