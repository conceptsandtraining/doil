#!/usr/bin/env bash

doil_update_20260617() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/autoinstall/*  /usr/local/share/doil/stack/states/autoinstall/

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        doil_status_send_message "Starting ${INSTANCE}"
        docker start ${INSTANCE} &> /dev/null
        sleep 5
        doil_status_okay

        doil_status_send_message "Apply patch to ${INSTANCE}"
        docker exec -it ${INSTANCE} /bin/bash -c "apt update && apt install jq ffmpeg -y" &> /dev/null
        docker exec -it ${INSTANCE} /bin/bash -c "jq -S '.mediaobject |= . + {\"path_to_ffmpeg\" : \"/usr/bin/ffmpeg\"}' /var/ilias/data/ilias-config.json > test.tmp && mv test.tmp /var/ilias/data/ilias-config.json" &> /dev/null
        docker exec -it ${INSTANCE} /bin/bash -c "if [ -d /var/www/html/public ]; then cd /var/www/html && php cli/setup.php update -y /var/ilias/data/ilias-config.json; else cd /var/www/html && php setup/setup.php update -y /var/ilias/data/ilias-config.json; fi" &> /dev/null
        docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
        doil_status_okay

        doil_status_send_message "Stoping ${INSTANCE}"
        docker stop ${INSTANCE} &> /dev/null
        doil_status_okay
    done
  fi

  return $?
}