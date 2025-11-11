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

function doil_system_remove() {
  ALL=$1

  if [ -d /usr/local/lib/doil ]
  then
    rm -rf /usr/local/lib/doil
  fi

  if [ -d /usr/local/share/doil ]
  then
    rm -rf /usr/local/share/doil
  fi

  if [ -d /var/log/doil ]
  then
    rm -rf /var/log/doil
  fi

  if [ -f /usr/local/bin/doil ]
  then
    rm /usr/local/bin/doil
  fi

  doil_system_stop_instances
  doil_system_rm_system_instances
  doil_system_remove_doil_system_images
  doil_system_remove_networks
  doil_system_remove_volumes
  doil_system_remove_hosts_entry

  delgroup doil >/dev/null 2>&1

  if [ ! -z ${ALL} ]
  then
    GLOBAL_INSTANCES_PATH=$(doil_get_conf global_instances_path)
    if [ -d "${GLOBAL_INSTANCES_PATH}" ]
    then
      rm -rf "${GLOBAL_INSTANCES_PATH}"
    fi

    doil_system_remove_instances
    doil_system_remove_all_images
    doil_system_remove_instances_on_disk

  fi

  doil_system_remove_user_doil_folders

  if [ -d /etc/doil ]
  then
    rm -rf /etc/doil
  fi

}

function doil_system_stop_instances() {
  if [ $(docker ps -q --filter "name=_local" --filter "name=_global" --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker kill $(docker ps -q --filter "name=_local" --filter "name=_global" --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_remove_instances() {
  if [ $(docker ps -a -q --filter "name=_local" --filter "name=_global" --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker rm $(docker ps -a -q --filter "name=_local" --filter "name=_global" --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_rm_system_instances() {
  if [ $(docker ps -a -q --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker rm $(docker ps -a -q --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_remove_all_images() {
  docker rmi -f $(docker images -q --filter reference=doil[/,_]*) >/dev/null 2>&1
}

function doil_system_remove_doil_system_images() {
  docker rmi -f $(docker images -q --filter reference=doil_*) >/dev/null 2>&1
  docker image prune -f >/dev/null 2>&1
}

function doil_system_remove_instances_on_disk() {
  if [ ! -z "$(find /home -type l | grep .doil)" ]
  then
    (find /home -type l | grep .doil | xargs realpath | xargs rm -rf) >/dev/null 2>&1
  fi
}

function doil_system_remove_networks() {
  if [ $(docker network ls -q --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker network  rm $(docker network ls -q --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_remove_volumes() {
  volumes=(
    doil_mail
    doil_sieve
    keycloak_admin
    keycloak_keycloak_1
  )

  for volume in "${strings[@]}"
  do
    docker volume rm "$volume" >/dev/null 2>&1
  done
}

function doil_system_remove_user_doil_folders() {
  find /home -name .doil -type d -exec rm -rf {} +
}

function doil_system_remove_hosts_entry() {
  HOST=$(doil_get_conf "host=")
  sed -i "/172.24.0.254 ${HOST}/d" /etc/hosts
}


