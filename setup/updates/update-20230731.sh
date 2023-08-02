#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20230731() {
  GLOBAL_INSTANCES_PATH=$(cat ${SCRIPT_DIR}/conf/doil.conf | grep "global_instances_path" | cut -d '=' -f 2-)

cat <<Message
Before running this update, you should make sure to customize the ${SCRIPT_DIR}/conf/doil.conf file according to
your needs. For more information, please read the README (https://github.com/conceptsandtraining/doil/blob/master/README.md).
In addition, global instances are always stored in the same place with this update. This place can also be set in the Doil Config.
By default, they are stored under /srv/instances. Current global instances are automatically moved to the directory specified
in the config.
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


  mkdir -p "${GLOBAL_INSTANCES_PATH}"
  chown -R root:doil "${GLOBAL_INSTANCES_PATH}"
  chmod g+w "${GLOBAL_INSTANCES_PATH}"
  chmod -R g+s "${GLOBAL_INSTANCES_PATH}"

  find /usr/local/share/doil/instances -type l | xargs realpath | xargs -I '{}' mv '{}' "${GLOBAL_INSTANCES_PATH}" 2>/dev/null
  rm /usr/local/share/doil/instances/*
  ls "${GLOBAL_INSTANCES_PATH}" | xargs -I '{}' ln -s "${GLOBAL_INSTANCES_PATH}"/{} /usr/local/share/doil/instances/{}
  update
  return $?
}
