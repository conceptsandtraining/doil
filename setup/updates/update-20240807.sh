#!/usr/bin/env bash

doil_update_20240807() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ /usr/local/share/doil/stack/states

  cp ${SCRIPT_DIR}/../setup/templates/mail/conf/salt-startup.sh /usr/local/lib/doil/server/mail/conf/

  cp ${SCRIPT_DIR}/../setup/templates/proxy/conf/salt-startup.sh /usr/local/lib/doil/server/proxy/conf/
  cp ${SCRIPT_DIR}/../setup/templates/proxy/conf/startup.conf /usr/local/lib/doil/server/proxy/conf/
  cp ${SCRIPT_DIR}/../setup/templates/proxy/docker-compose.yml /usr/local/lib/doil/server/proxy/

  chmod +x /usr/local/lib/doil/server/proxy/conf/salt-startup.sh

  if [ $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}" | wc -l) -gt 0 ]
  doil_status_send_message "Prepare existing instances to work with new doil"
  then
    for INSTANCE in $(docker ps -a --filter "name=_local" --filter "name=_global" --format "{{.Names}}")
    do
        docker start ${INSTANCE} &> /dev/null
        sleep 5
        docker exec -it ${INSTANCE} /bin/bash -c "sed -i 's%/var/lib/salt/pki/minion/minion_master.pub%/etc/salt/pki/minion/minion_master.pub%g' /root/salt-startup.sh" &> /dev/null
        docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
        docker stop ${INSTANCE} &> /dev/null
    done
  doil_status_okay
  fi

  return $?
}