#!/usr/bin/env bash

doil_update_20250908() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/mailservices/mailservices/* /usr/local/share/doil/stack/states/mailservices/mailservices/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/keycloak/keycloak/delete_keycloak_client.sh.j2 /usr/local/share/doil/stack/states/keycloak/keycloak/delete_keycloak_client.sh.j2
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias-update-hook/ilias-update-hook/update_hook.php.j2  /usr/local/share/doil/stack/states/ilias-update-hook/ilias-update-hook/update_hook.php.j2
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias/* /usr/local/share/doil/stack/states/ilias/

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        NAME=${INSTANCE%_*}
        SUFFIX=${INSTANCE##*_}
        GLOBAL=""
        if [ "${SUFFIX}" == "global" ]
        then
          GLOBAL="-g"
        fi

        doil up ${NAME} ${GLOBAL} &> /dev/null
        sleep 5

        doil_status_send_message "Apply state ilias-update-hook to ${NAME}"
        docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' state.highstate saltenv=ilias-update-hook" &> /dev/null
        doil_status_okay

        doil_status_send_message "Apply state ilias to ${NAME}"
        docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' state.highstate saltenv=ilias" &> /dev/null
        doil_status_okay

        doil_status_send_message "Commit image for ${NAME}"
        docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
        doil_status_okay

        docker stop ${INSTANCE} &> /dev/null
    done
  fi

  return $?
}