#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20230919() {
  update

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  doil_status_send_message "Remove .config/composer bind from docker-compose file"
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        NAME=$(echo ${INSTANCE%_*})
        SUFFIX=$(echo ${INSTANCE##*_})

        if [ "${SUFFIX}" == "global" ]
        then
          INSTANCE_PATH=$(/usr/local/bin/doil path "${NAME}" -g -p)
        else
          INSTANCE_PATH=$(su -c "/usr/local/bin/doil path ${NAME} -p" ${SUDO_USER})
        fi

        INSTANCE_PATH="${INSTANCE_PATH}/docker-compose.yml"
        LINE_NUMBER="$(grep -n 'source: ~/.config/composer/' "${INSTANCE_PATH}")"

        if [ ! -z "${LINE_NUMBER}" ]
        then
          LINE_NUMBER=${LINE_NUMBER%%:*}
          sed -i "$((LINE_NUMBER-1)),$((LINE_NUMBER+1))d" $INSTANCE_PATH
        fi

    done
  doil_status_okay
  fi

  return $?
}
