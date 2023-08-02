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

doil_get_conf() {
  CONFIG=${1}
  VALUE=""
  if [ -f /etc/doil/doil.conf ]
  then
    VALUE=$(cat /etc/doil/doil.conf | grep ${CONFIG} | cut -d '=' -f 2-)
  fi
  echo ${VALUE}
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

function doil_get_doil_version() {
  VERSION=$(/usr/local/bin/doil --version | cut -d ' ' -f 3)
  echo ${VERSION}
}

function doil_perform_update() {
  declare -a UPDATES

  # No doil binary found > no update
  # Prevents a file not found error in doil_get_doil_version() if update.sh is called without an existing version
  if [ ! -f "/usr/local/bin/doil" ]
  then
    echo "No current doil version found at /usr/local/bin/doil."
    exit
  fi

  # if we are on a version somewhere around 1.4 we need
  # to apply all of the updates
  # otherwise we only apply the updates we need
  DOIL_VERSION=$(doil_get_doil_version)
  DOIL_VERSION_SIZE=${#DOIL_VERSION}

  doil_test_version_compare "8" ${DOIL_VERSION_SIZE} "="
  if [[ $? -ne 0 || ${DOIL_VERSION} -lt "20221110" ]]
  then
    echo "Your doil version is no longer supported by this update. Please read the README.md for more information."
    exit
  fi

  for UPDATE_FILE in $(find ${SCRIPT_DIR}/updates/ -type f -name "update-*")
  do
    source ${UPDATE_FILE}
    for UPDATE in $(set | grep  -E '^doil_update.* \(\)' | sed -e 's: .*::')
    do
      if [[ ! " ${UPDATES[@]} " =~ " ${UPDATE} " ]]
      then
        UPDATES=("${UPDATES[@]}" ${UPDATE})
        UPDATE_NAME=$(echo ${UPDATE} | cut -d "_" -f 3)

        doil_test_version_compare ${DOIL_VERSION} ${UPDATE_NAME} "<"

        if [ $? -ne 0 ]
        then
          continue
        fi

        echo "Apply patch ${UPDATE_NAME}"
        doil_perform_single_update ${UPDATE}
      fi
    done
  done
}

doil_perform_single_update() {
  "${1}"
}