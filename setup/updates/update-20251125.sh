#!/usr/bin/env bash

doil_update_20251125() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/nodejs/* /usr/local/share/doil/stack/states/nodejs/

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

        doil_status_send_message "Apply state ilias to ${NAME}"
        docker exec -it "${INSTANCE}" /bin/bash -c "rm -rf /etc/apt/sources.list.d/salt.list" &> /dev/null
        docker exec -it "${INSTANCE}" /bin/bash -c "salt 'curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp" &> /dev/null
        docker exec -it "${INSTANCE}" /bin/bash -c "salt 'curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources" &> /dev/null
        doil_status_okay

        docker stop ${INSTANCE} &> /dev/null
      done
    fi
  return $?
}