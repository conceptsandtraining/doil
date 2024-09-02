#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20241113() {

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

  HOST=$(cat /etc/doil/doil.conf | grep "host=" | cut -d '=' -f 2-)
  if [ -n "$(ls -A /home/${SUDO_USER}/.doil/instances)" ]
  then
    for FILE in $(find -L /home/"${SUDO_USER}"/.doil/instances -maxdepth 2 -iname "docker-compose.yml" | xargs realpath)
    do
      if ! grep -q "extra_hosts:" "$FILE"
      then
        sed -i -e "s/^\([[:space:]]*\)volumes:/\1extra_hosts:\n\1  - \"${HOST}:172.24.0.254\"\n\1volumes:/g" "$FILE"
      fi
    done
  fi

  GLOBAL_INSTANCES_PATH=$(cat /etc/doil/doil.conf | grep "global_instances_path" | cut -d '=' -f 2-)
  if [ -n "$(ls -A "${GLOBAL_INSTANCES_PATH}")" ]
  then
    for FILE in $(find -L "${GLOBAL_INSTANCES_PATH}" -maxdepth 2 -iname "docker-compose.yml" | xargs realpath)
    do
      if ! grep -q "extra_hosts:" "$FILE"
      then
        sed -i -e "s/^\([[:space:]]*\)volumes:/\1extra_hosts:\n\1  - \"${HOST}:172.24.0.254\"\n\1volumes:/g" "$FILE"
      fi
    done
  fi

  return $?
}