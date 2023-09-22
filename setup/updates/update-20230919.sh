#!/usr/bin/env bash

source "${SCRIPT_DIR}"/updates/update.sh

doil_update_20230919() {
  echo ""
  echo "This update disables Xdebug on all instances. In order to continue using xdebug,"
  echo "you must run 'doil apply <instance_name> enable-xdebug' for the desired instances after the update."
  echo ""

  update

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  doil_status_send_message "Applying patch on existing instances"
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        NAME=${INSTANCE%_*}
        SUFFIX=${INSTANCE##*_}

        if [ "${SUFFIX}" == "global" ]
        then
          INSTANCE_PATH=$(/usr/local/bin/doil path "${NAME}" -g -p)
          su -c "/usr/local/bin/doil apply ${NAME} disable-xdebug -g" "${SUDO_USER}" 2>&1 > /dev/null
        else
          INSTANCE_PATH=$(su -c "/usr/local/bin/doil path ${NAME} -p" "${SUDO_USER}")
          su -c "/usr/local/bin/doil apply ${NAME} disable-xdebug" "${SUDO_USER}" 2>&1 > /dev/null
        fi

        DOCKER_COMPOSE_PATH="${INSTANCE_PATH}/docker-compose.yml"
        LINE_NUMBER="$(grep -n 'source: ~/.config/composer/' "${DOCKER_COMPOSE_PATH}")"

        if [ ! -z "${LINE_NUMBER}" ]
        then
          LINE_NUMBER=${LINE_NUMBER%%:*}
          sed -i "$((LINE_NUMBER-1)),$((LINE_NUMBER+1))d" "${DOCKER_COMPOSE_PATH}"
        fi

        mkdir "${INSTANCE_PATH}"/volumes/logs/xdebug
        chmod 775 "${INSTANCE_PATH}"/volumes/logs/xdebug
        if [ "${SUFFIX}" == "global" ]
        then
          chown root:doil "${INSTANCE_PATH}"/volumes/logs/xdebug
        else
          chown "${SUDO_USER}":"${SUDO_USER}" "${INSTANCE_PATH}"/volumes/logs/xdebug
        fi

        sed -i 's/volumes:/&\n      - type: bind\n        source: .\/volumes\/logs\/xdebug\n        target: \/var\/log\/doil\/xdebug/' "${DOCKER_COMPOSE_PATH}"

    done
  doil_status_okay
  fi

  return $?
}
