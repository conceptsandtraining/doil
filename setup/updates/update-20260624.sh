#!/usr/bin/env bash

doil_update_20260624() {

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

  sed -i "1s/^/enable-office=${INSTALL}\n/" /etc/doil/doil.conf

  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/config/* /usr/local/share/doil/stack/config/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/enable-office /usr/local/share/doil/stack/states/enable-office
  cp -r ${SCRIPT_DIR}/../setup/stack/states/disable-office /usr/local/share/doil/stack/states/disable-office
  cp -r ${SCRIPT_DIR}/../setup/templates/office /usr/local/lib/doil/server/office

  chown -R root:doil /usr/local/lib/doil/server/office
  chmod -R +x /usr/local/lib/doil/server/office

  if [[ $INSTALL == "true" ]]
  then
    cd /usr/local/lib/doil/server/office
    BUILD=$(docker compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
    sleep 20
    docker exec -i doil_office bash -c "grep -qxF '172.24.0.254    doil' /etc/hosts || echo '172.24.0.254    doil' >> /etc/hosts" 2>&1 > /var/log/doil/stream.log
  fi

  doil salt:restart

  return $?
}