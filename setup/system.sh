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

function doil_system_add_user_to_doil_group() {
  id -nG $SUDO_USER | grep -qw 'doil'
    if [[ $? -ne 0 ]]
      then
        usermod -a -G doil ${SUDO_USER}
      fi
    return 0
}

function doil_system_create_folder() {

  if [ ! -d /usr/local/lib/doil ]
  then
    mkdir /usr/local/lib/doil
  fi

  if [ ! -d /usr/local/lib/doil/app ]
  then
    mkdir /usr/local/lib/doil/app
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

  cp setup/doil.sh /usr/local/bin/doil
  cp -r app/* /usr/local/lib/doil/app/
  cp -r setup/templates/mail /usr/local/lib/doil/server/
  cp -r setup/templates/proxy /usr/local/lib/doil/server/
  cp -r setup/templates/salt /usr/local/lib/doil/server/
  cp -r setup/templates/minion /usr/local/share/doil/templates
  cp -r setup/stack/* /usr/local/share/doil/stack

  return 0
}

function doil_system_run_composer() {

  COMPOSER=$(which composer)
  COMPOSER_ALLOW_SUPERUSER=1 ${COMPOSER} -d /usr/local/lib/doil/app/ install -n -q

  return 0
}

function doil_system_replace_salt_stack() {

  rm -rf /usr/local/share/doil/stack/*
  cp -r setup/stack/* /usr/local/share/doil/stack

  return 0
}

function doil_system_setup_config() {

  cp setup/conf/doil.conf /etc/doil/doil.conf

  if [ ! -f /etc/doil/repositories.json ]
  then
    touch /etc/doil/repositories.json
  fi

  if [ ! -f /etc/doil/user.json ]
  then
    touch /etc/doil/user.json
  fi

  # ilias repo
  echo '"a:1:{i:1;O:27:\"CaT\\Doil\\Commands\\Repo\\Repo\":3:{s:7:\"\u0000*\u0000name\";s:5:\"ilias\";s:6:\"\u0000*\u0000url\";s:44:\"https://github.com/ILIAS-eLearning/ILIAS.git\";s:9:\"\u0000*\u0000global\";b:1;}}"' > "/etc/doil/repositories.json"

  chown -R root:doil /etc/doil

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
  chown -R root:doil /var/log/doil/

  chmod g+w /etc/doil/repositories.json
  chmod g+w /etc/doil/user.json
  chmod -R g+w /etc/doil
  chmod -R g+s /etc/doil
  chmod -R g+w /usr/local/share/doil/instances
  chmod -R g+s /usr/local/share/doil/instances
  chmod -R g+w /usr/local/share/doil/repositories
  chmod -R g+s /usr/local/share/doil/repositories
  chmod +x /usr/local/bin/doil
  chmod -R 777 /usr/local/lib/doil/server/proxy/conf/
  chmod -R 777 /var/log/doil/

  return 0
}

function doil_system_setup_userconfig() {

  HOME=$(eval echo "~${SUDO_USER}")

  if [ ! -d ${HOME}/.doil/ ]
  then
    mkdir ${HOME}/.doil/
  fi

  if [ ! -d ${HOME}/.doil/config/ ]
  then
    mkdir ${HOME}/.doil/config/
  fi

  if [ ! -f ${HOME}/.doil/config/repositories.json ]
  then
    touch ${HOME}/.doil/config/repositories.json
  fi

  if [ ! -d ${HOME}/.doil/repositories ]
  then
    mkdir ${HOME}/.doil/repositories
  fi

  if [ ! -d ${HOME}/.doil/instances ]
  then
    mkdir ${HOME}/.doil/instances
  fi

  chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"

  USEREXISTS=$(grep "${SUDO_USER}" /etc/doil/user.json)
  if [[ -z ${USEREXISTS} ]]
  then
    echo '"a:1:{i:0;O:27:\"CaT\\Doil\\Commands\\User\\User\":1:{s:7:\"\u0000*\u0000name\";s:'${#SUDO_USER}':\"'${SUDO_USER}'\";}}"' >> "/etc/doil/user.json"
  fi

  return 0
}

function doil_system_setup_log() {
  if [[ ! -d /var/log/doil/ ]]
  then
    mkdir /var/log/doil/
  fi

  if [[ ! -f /var/log/doil/stream.log ]]
  then
    touch /var/log/doil/stream.log
  fi
}

function doil_system_stop_all_services() {
  doil system:proxy stop
  doil system:salt stop
}

function doil_system_remove_services() {
  docker image rm doil_proxy --force 2>&1 > /var/log/doil/stream.log
  docker image rm saltmain --force 2>&1 > /var/log/doil/stream.log
}

function doil_system_install_saltserver() {
  cd /usr/local/lib/doil/server/salt
  BUILD=$(docker-compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  docker commit doil_saltmain doil_saltmain:stable 2>&1 > /var/log/doil/stream.log
}

function doil_system_install_proxyserver() {
  cd /usr/local/lib/doil/server/proxy
  NAME=$(cat /etc/doil/doil.conf | grep "host" | cut -d '=' -f 2-)
  sed -i "s/%TPL_SERVER_NAME%/${NAME}/g" "/usr/local/lib/doil/server/proxy/conf/nginx/local.conf"
  BUILD=$(docker-compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  sleep 10
  docker exec -i doil_saltmain bash -c "salt 'doil.proxy' state.highstate saltenv=proxyservices" 2>&1 > /var/log/doil/stream.log
  docker commit doil_proxy doil_proxy:stable 2>&1 > /var/log/doil/stream.log
}

function doil_system_install_mailserver() {
  cd /usr/local/lib/doil/server/mail
  BUILD=$(docker-compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  sleep 10
  docker exec -i doil_saltmain bash -c "salt 'doil.postfix' state.highstate saltenv=mailservices" 2>&1 > /var/log/doil/stream.log
  docker commit doil_postfix doil_postfix:stable 2>&1 > /var/log/doil/stream.log
}
