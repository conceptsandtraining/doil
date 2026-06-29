#!/usr/bin/env bash

doil_update_20260714() {

cat <<Message
This update prepares Doil to deploy an Office Server.
Depending on your decision, it will be installed directly alongside this update.

For more information, please read the README (https://github.com/conceptsandtraining/doil/blob/master/README.md).
Message

  read -r -p "Would you like to install the Office Server? [y/N] " RESPONSE
  case "$RESPONSE" in
      [yY][eE][sS]|[yY])
          INSTALL="true";;
      *)
          INSTALL="false"
          ;;
  esac

  docker compose -f /usr/local/lib/doil/server/office/docker-compose.yml down >/var/log/doil/stream.log 2>&1
  docker image rm rabbitmq:3 >/var/log/doil/stream.log 2>&1
  docker image rm postgres:15 >/var/log/doil/stream.log 2>&1
  docker image rm onlyoffice/documentserver:9.4 >/var/log/doil/stream.log 2>&1

  sed -i '/enable_office=/d' /etc/doil/doil.conf >/var/log/doil/stream.log 2>&1
  sed -i "1s/^/enable_office=${INSTALL}\n/" /etc/doil/doil.conf >/var/log/doil/stream.log 2>&1

  rm -rf /usr/local/share/doil/stack/states/enable-office >/var/log/doil/stream.log 2>&1
  rm -rf /usr/local/share/doil/stack/states/disable-office >/var/log/doil/stream.log 2>&1
  rm -rf /usr/local/lib/doil/server/office >/var/log/doil/stream.log 2>&1

  chown -R root:doil /usr/local/share/doil/stack/states >/var/log/doil/stream.log 2>&1

  mkdir -p /usr/local/share/doil/stack/states/enable-office >/var/log/doil/stream.log 2>&1
  mkdir -p /usr/local/share/doil/stack/states/disable-office >/var/log/doil/stream.log 2>&1
  mkdir -p /usr/local/lib/doil/server/office >/var/log/doil/stream.log 2>&1

  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/config/* /usr/local/share/doil/stack/config/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/enable-office/* /usr/local/share/doil/stack/states/enable-office/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/disable-office/* /usr/local/share/doil/stack/states/disable-office/
  cp -r ${SCRIPT_DIR}/../setup/templates/office/* /usr/local/lib/doil/server/office/
  cp -r ${SCRIPT_DIR}/../setup/templates/proxy/conf/nginx/* /usr/local/lib/doil/server/proxy/conf/nginx/
  cp -r ${SCRIPT_DIR}/../setup/templates/minion/docker-compose.yml /usr/local/share/doil/templates/minion/docker-compose.yml

  chown -R root:doil /usr/local/lib/doil/server/office
  chmod -R +x /usr/local/lib/doil/server/office

  if [[ $INSTALL == "true" ]]
  then
    cd /usr/local/lib/doil/server/office
    BUILD=$(docker compose up -d >/var/log/doil/stream.log 2>&1) >/var/log/doil/stream.log 2>&1
    sleep 20
    docker exec -i doil_office bash -c "grep -qxF '172.24.0.254    doil' /etc/hosts || echo '172.24.0.254    doil' >> /etc/hosts" >/var/log/doil/stream.log 2>&1
  fi

  doil salt:restart
  doil_system_install_proxyserver

  return $?
}