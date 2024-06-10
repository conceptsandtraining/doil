#!/usr/bin/env bash

doil_update_20250226() {

cat <<Message
Before running this update, you should make sure to customize the ${SCRIPT_DIR}/conf/doil.conf file according to
your needs. For more information, please read the README (https://github.com/conceptsandtraining/doil/blob/master/README.md).
Message

  read -r -p "Do you want to proceed? [y/N] " RESPONSE
  case "$RESPONSE" in
      [yY][eE][sS]|[yY])
          ;;
      *)
          echo "Abort by user!"
          exit 1
          ;;
  esac

  cp -f ${SCRIPT_DIR}/conf/doil.conf /etc/doil/doil.conf
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/* /usr/local/share/doil/stack/states/
  cp -r ${SCRIPT_DIR}/../setup/stack/config/* /usr/local/share/doil/stack/config/
  cp -r ${SCRIPT_DIR}/../setup/templates/minion/* /usr/local/share/doil/templates/minion/
  cp -r ${SCRIPT_DIR}/../setup/templates/proxy/conf/* /usr/local/lib/doil/server/proxy/conf/

  doil salt:restart
  doil proxy:restart
  sleep 10

  NAME=$(cat /etc/doil/doil.conf | grep "host=" | cut -d '=' -f 2-)
  UPDATE_TOKEN=$(cat /etc/doil/doil.conf | grep "update_token=" | cut -d '=' -f 2-)
  sed -i "s/%TPL_SERVER_NAME%/${NAME}/g" "/usr/local/lib/doil/server/proxy/conf/nginx/local.conf"
  docker exec -it doil_saltmain /bin/bash -c "salt \"doil.proxy\" state.highstate saltenv=proxyservices" &> /dev/null
  docker commit doil_proxy doil_proxy:stable &> /dev/null

  doil proxy:reload

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  doil_status_send_message "Applying patch on existing instances"
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        STARTED=0
        NAME=${INSTANCE%_*}
        SUFFIX=${INSTANCE##*_}

        if [ -L /usr/local/share/doil/instances/"${NAME}" ] || [ -L /home/"${SUDO_USER}"/.doil/instances/"${NAME}" ]
        then
          if [ "${SUFFIX}" == "global" ]
          then
            INSTANCE_PATH=$(/usr/local/bin/doil path "${NAME}" -g -p)
            GLOBAL="-g"
          else
            INSTANCE_PATH=$(su -c "/usr/local/bin/doil path ${NAME} -p" "${SUDO_USER}")
            GLOBAL=""
          fi

          if [[ ! $(docker ps --filter "name=_local" --filter "name=_global" --format "{{.Names}}") =~ ${INSTANCE} ]]
          then
            doil up ${NAME} ${GLOBAL}
            STARTED=1
          fi

          DOCKER_COMPOSE_PATH="${INSTANCE_PATH}/docker-compose.yml"

          if ! grep -q "target: /var/www/.ssh" "${DOCKER_COMPOSE_PATH}"
          then
            sed -i 's/volumes:/&\n      - type: bind\n        source: ~\/.ssh\/\n        target: \/var\/www\/.ssh/' "${DOCKER_COMPOSE_PATH}"
          fi
          sleep 5
          if [ "${UPDATE_TOKEN}" != "false" ]
          then
            docker exec -it doil_saltmain /bin/bash -c "salt \"${NAME}.${SUFFIX}\" state.highstate saltenv=ilias-update-hook" &> /dev/null
          fi
          if [ ${STARTED} == 1 ]
          then
            doil down ${NAME} ${GLOBAL}
          else
            doil restart ${NAME} ${GLOBAL}
          fi
        fi
    done

    if [ "${UPDATE_TOKEN}" != "false" ]
    then
      doil sut -q -a -t "${UPDATE_TOKEN}" &> /dev/null
      doil sut -q -a -t "${UPDATE_TOKEN}" -g &> /dev/null
    fi

    doil_status_okay
  fi

  return $?
}