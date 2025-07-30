#!/usr/bin/env bash

doil_update_20250730() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias/* /usr/local/share/doil/stack/states/ilias

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
    doil_status_send_message "Prepare existing instances to work with new doil"
    then
      for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
      do
          docker start ${INSTANCE} &> /dev/null
          sleep 5
          docker exec -it doil_saltmain /bin/bash -c "salt \"${NAME}.${SUFFIX}\" state.highstate saltenv=ilias" &> /dev/null
          docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
          docker stop ${INSTANCE} &> /dev/null
      done
    doil_status_okay
    fi

  return $?
}