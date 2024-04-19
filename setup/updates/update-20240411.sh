#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20240411() {
  update

  doil_status_send_message "Removing obsolete 'version: ...' line from docker-compose.yml files"
  # removes the obsolete version line from all global docker-compose.yml files
  GLOBAL_INSTANCES_PATH=$(cat ${SCRIPT_DIR}/conf/doil.conf | grep "global_instances_path" | cut -d '=' -f 2-)
  readarray -d '' array < <(find ${GLOBAL_INSTANCES_PATH} -maxdepth 2 -iname "docker-compose.yml" -print0)
  for i in "${array[@]}"
  do
    if [[ $(head -n 1 "${i}") =~ ^version* ]]
    then
      tail -n +2 "${i}" > tmp.yml && mv tmp.yml "${i}"
    fi
  done

  # removes the obsolete version line from all local docker-compose.yml files
  HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
  readarray -d '' array < <(find -L ${HOME}/.doil/instances -maxdepth 2 -iname "docker-compose.yml" -print0)
    for i in "${array[@]}"
    do
      if [[ $(head -n 1 "${i}") =~ ^version* ]]
      then
        tail -n +2 "${i}" > tmp.yml && mv tmp.yml "${i}"
      fi
    done
  doil_status_okay

  return $?
}
