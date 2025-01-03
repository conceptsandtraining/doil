#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20241206() {

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

  update

  HTTPS_PROXY=$(cat /etc/doil/doil.conf | grep "https_proxy=" | cut -d '=' -f 2-)
  if [ "${HTTPS_PROXY}" == "true" ]
  then
    if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
    then
      doil_status_send_message "Prepare existing instances to work with new doil"
      HOST=$(cat /etc/doil/doil.conf | grep "host=" | cut -d '=' -f 2-)
      NEEDLE="http://${HOST}"
      REPLACE="https://${HOST}"
      for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
      do
          docker start ${INSTANCE} &> /dev/null
          sleep 5
          docker exec -it ${INSTANCE} /bin/bash -c "sed -i 's%${NEEDLE}%${REPLACE}%g' /var/ilias/data/ilias-config.json" &> /dev/null
          docker exec -it ${INSTANCE} /bin/bash -c "cd /var/www/html && php setup/setup.php update -y /var/ilias/data/ilias-config.json" &> /dev/null
          NAME=$(echo "${INSTANCE%_*}")
          SUFFIX=$(echo "${INSTANCE}" | rev | cut -d "_" -f 1 | rev)
          GLOBAL_PARAM="-g"
          if [ "${SUFFIX}" == "local" ]
          then
            GLOBAL_PARAM=""
          fi
          doil apply "${NAME}" "${GLOBAL_PARAM}" enable-https
          docker exec -it ${INSTANCE} /bin/bash -c "salt-call grains.set doil_domain ${REPLACE}/${NAME}"
          doil apply "${NAME}" "${GLOBAL_PARAM}" access
          docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
          docker stop ${INSTANCE} &> /dev/null
      done
    doil_status_okay
    fi
  fi

  return $?
}