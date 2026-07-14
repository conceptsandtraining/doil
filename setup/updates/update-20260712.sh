#!/usr/bin/env bash

doil_update_20260712() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/dev/*  /usr/local/share/doil/stack/states/dev/
  cp -r ${SCRIPT_DIR}/../setup/templates/salt/docker-compose.yml  /usr/local/lib/doil/server/salt/
  cp -r ${SCRIPT_DIR}/../setup/templates/mail/docker-compose.yml  /usr/local/lib/doil/server/mail/
  cp -r ${SCRIPT_DIR}/../setup/templates/proxy/docker-compose.yml  /usr/local/lib/doil/server/proxy/

  apt-get install yq -y >/var/log/doil/stream.log 2>&1
  NOT_AVAILABLE=$?

  if [[ $NOT_AVAILABLE != 0 ]]
  then
    echo "Can't install yq on your system. Only new created doil instances will show a health check."
    exit 0
  fi

  for DIR in /home/$SUDO_USER/.doil/instances/*
  do
    if [[ -f "$DIR"/docker-compose.yml ]]
    then
      yq --yaml-output '.services[].healthcheck |= . + {"test": "curl -f http://localhost && mysql -u root --execute \"SHOW DATABASES;\" || exit 1", "interval": "10s", "timeout": "5s", "retries": 3, "start_period": "40s", "start_interval": "5s"}' "${DIR}"/docker-compose.yml > "${DIR}"/tmp.yml && mv "${DIR}"/tmp.yml "${DIR}"/docker-compose.yml >/var/log/doil/stream.log 2>&1
    fi
  done

  for DIR in $(doil_get_conf global_instances_path=)/*
  do
    if [[ -f "$DIR"/docker-compose.yml ]]
    then
      yq --yaml-output '.services[].healthcheck |= . + {"test": "curl -f http://localhost && mysql -u root --execute \"SHOW DATABASES;\" || exit 1", "interval": "10s", "timeout": "5s", "retries": 3, "start_period": "40s", "start_interval": "5s"}' "${DIR}"/docker-compose.yml > "${DIR}"/tmp.yml && mv "${DIR}"/tmp.yml "${DIR}"/docker-compose.yml >/var/log/doil/stream.log 2>&1
    fi
  done

  apt-get remove yq -y >/var/log/doil/stream.log 2>&1

  return $?
}