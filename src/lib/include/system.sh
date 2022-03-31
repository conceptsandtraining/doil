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

function doil_system_remove_old_version() {

  # removing old version
  if [ -f "/usr/local/bin/doil" ]
  then
    rm /usr/local/bin/doil
  fi
  if [ -d "/usr/local/lib/doil" ]
  then
    rm -rf /usr/local/lib/doil/lib
  fi
  return 0
}

function doil_system_add_group() {

  CHECK_GROUP=$(grep doil /etc/group)
  if [[ -z ${CHECK_GROUP} ]]
  then
    groupadd doil
  fi

  return 0
}

function doil_system_create_folder() {

  if [ ! -d /usr/local/lib/doil ]
  then
    mkdir /usr/local/lib/doil
  fi

  if [ ! -d /usr/local/lib/doil/lib ]
  then
    mkdir /usr/local/lib/doil/lib
  fi

  if [ ! -d /usr/local/lib/doil/server ]
  then
    mkdir /usr/local/lib/doil/server
  fi

  if [ ! -d /etc/doil ]
  then
    mkdir /etc/doil/
  fi

  if [ ! -d /usr/local/share/doil ]
  then
    mkdir /usr/local/share/doil
  fi

  if [ ! -d /usr/local/share/doil/templates ]
  then
    mkdir /usr/local/share/doil/templates
  fi

  if [ ! -d /usr/local/share/doil/instances ]
  then
    mkdir /usr/local/share/doil/instances
  fi

  if [ ! -d /usr/local/share/doil/stack ]
  then
    mkdir /usr/local/share/doil/stack
  fi

  if [ ! -d /usr/local/share/doil/instances ]
  then
    mkdir /usr/local/share/doil/instances
  fi

  if [ ! -d /usr/local/share/doil/repositories ]
  then
    mkdir /usr/local/share/doil/repositories
  fi

  return 0
}

function doil_system_copy_doil() {

  cp src/doil.sh /usr/local/bin/doil
  cp -r src/lib/* /usr/local/lib/doil/lib/
  cp -r src/server/* /usr/local/lib/doil/server/
  cp -r src/templates/* /usr/local/share/doil/templates
  cp -r src/stack/* /usr/local/share/doil/stack

  return 0
}

function doil_system_setup_config() {

  if [ ! -f /etc/doil/doil.conf ]
  then
    cp src/conf/doil.conf /etc/doil/doil.conf
  fi

  if [ ! -f /etc/doil/repositories.conf ]
  then
    touch /etc/doil/repositories.conf
  fi

  if [ ! -f /etc/doil/user.conf ]
  then
    touch /etc/doil/user.conf
  fi

  # ilias repo
  echo "ilias=git@github.com:ILIAS-eLearning/ILIAS.git" > "/etc/doil/repositories.conf"

  return 0
}

function doil_system_setup_ip() {

  IPEXIST=$(grep "172.24.0.254" /etc/hosts)
  if [[ -z ${IPEXIST} ]]
  then
    printf "172.24.0.254 doil" >> "/etc/hosts"
  fi
  return 0
}

function doil_system_setup_access() {

  chown -R root:doil /usr/local/lib/doil
  chown -R root:doil /etc/doil
  chown -R root:doil /usr/local/share/doil
  chown root:doil /usr/local/bin/doil
  chown -R root:doil /usr/local/lib/doil/server
  chown -R root:doil /usr/local/lib/doil/lib
  chown root:doil /usr/local/share/doil/templates
  chown -R root:doil /usr/local/share/doil/stack
  chown -R root:doil /usr/local/share/doil/repositories
  chown -R root:doil /usr/local/share/doil/instances
  chown -R root:doil /etc/doil/
  chown root:doil /var/log/doil.log

  chmod g+w /etc/doil/repositories.conf
  chmod g+w /etc/doil/user.conf
  chmod -R g+w /etc/doil
  chmod -R g+s /etc/doil
  chmod -R g+w /usr/local/share/doil/instances
  chmod -R g+s /usr/local/share/doil/instances
  chmod -R g+w /usr/local/share/doil/repositories
  chmod -R g+s /usr/local/share/doil/repositories
  chmod +x /usr/local/bin/doil
  chmod -R +x /usr/local/lib/doil/lib
  chmod -R 777 /usr/local/lib/doil/server/proxy/conf/
  chmod 777 /var/log/doil.log

  return 0
}

function doil_system_setup_userconfig() {

  HOME=$(eval echo "~${SUDO_USER}")

  if [ ! -d ${HOME}/.doil/ ]
  then
    mkdir ${HOME}/.doil/
  fi

  if [ ! -f ${HOME}/.doil/config/repositories.conf ]
  then
    mv ${HOME}/.doil/config/repos ${HOME}/.doil/config/repositories.conf
  fi

  if [ ! -d ${HOME}/.doil/repositories ]
  then
    mkdir ${HOME}/.doil/repositories
    if [ -d /usr/local/lib/doil/tpl/repos ]
    then
      mv /usr/local/lib/doil/tpl/repos ${HOME}/.doil/repositories
    fi
  fi

  if [ ! -d ${HOME}/.doil/instances ]
  then
    mkdir ${HOME}/.doil/instances
    for LINK in $(ls ${HOME}/.doil)
    do
      if [[ ${LINK} == "config" ]]
      then
        continue
      fi
      mv ${LINK} ${HOME}/.doil/instances/${LINK}
    done
  fi

  chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"
  usermod -a -G doil ${SUDO_USER}

  USEREXISTS=$(grep "${SUDO_USER}" /etc/doil/user.conf)
  if [[ -z ${USEREXISTS} ]]
  then
    echo "${SUDO_USER}" >> "/etc/doil/user.conf"
  fi

  return 0
}

function doil_system_touch_log_file() {
  if [[ ! -f /var/log/doil.log ]]
  then
    touch /var/log/doil.log
  fi
}