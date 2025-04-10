#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2023 Daniel Weise (daniel.weise@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

function doil_system_remove_old_version() {
  # removing old version
  if [ -d /usr/local/lib/doil ]
  then
    rm -rf /usr/local/lib/doil
  fi

  if [ -d /usr/local/share/doil/stack ]
  then
    rm -rf /usr/local/share/doil/stack
  fi

  if [ -d /usr/local/share/doil/templates ]
  then
    rm -rf /usr/local/share/doil/templastes
  fi

  return 0
}

function doil_system_remove() {
  ALL=$1

  if [ -d /usr/local/lib/doil ]
  then
    rm -rf /usr/local/lib/doil
  fi

  if [ -d /usr/local/share/doil ]
  then
    rm -rf /usr/local/share/doil
  fi

  if [ -d /var/log/doil ]
  then
    rm -rf /var/log/doil
  fi

  if [ -f /usr/local/bin/doil ]
  then
    rm /usr/local/bin/doil
  fi

  doil_system_stop_instances
  doil_system_rm_system_instances
  doil_system_remove_doil_system_images
  doil_system_remove_networks
  doil_system_remove_volumes
  doil_system_remove_user_doil_folders
  doil_system_remove_hosts_entry

  delgroup doil

  if [ ! -z ${ALL} ]
  then
    GLOBAL_INSTANCES_PATH=$(doil_get_conf global_instances_path)
    if [ -d "${GLOBAL_INSTANCES_PATH}" ]
    then
      rm -rf "${GLOBAL_INSTANCES_PATH}"
    fi

    doil_system_remove_instances
    doil_system_remove_all_images
    doil_system_remove_instances_on_disk

  fi

  if [ -d /etc/doil ]
  then
    rm -rf /etc/doil
  fi

}

function doil_system_stop_instances() {
  if [ $(docker ps -q --filter "name=_local" --filter "name=_global" --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker kill $(docker ps -q --filter "name=_local" --filter "name=_global" --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_remove_instances() {
  if [ $(docker ps -a -q --filter "name=_local" --filter "name=_global" --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker rm $(docker ps -a -q --filter "name=_local" --filter "name=_global" --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_rm_system_instances() {
  if [ $(docker ps -a -q --filter "name=doil_" | wc -l) -gt 0 ]
  then
    (docker rm $(docker ps -a -q --filter "name=doil_")) >/dev/null 2>&1
  fi
}

function doil_system_remove_all_images() {
  docker rmi -f $(docker images -q --filter reference=doil[/,_]*) >/dev/null 2>&1
}

function doil_system_remove_doil_system_images() {
  docker rmi -f $(docker images -q --filter reference=doil_*) >/dev/null 2>&1
  docker image prune -f >/dev/null 2>&1
}

function doil_system_remove_instances_on_disk() {
  if [ ! -z "$(find /home -type l | grep .doil)" ]
  then
    (find /home -type l | grep .doil | xargs realpath | xargs rm -rf) >/dev/null 2>&1
  fi
}

function doil_system_remove_networks() {
  docker network prune -f >/dev/null 2>&1
}

function doil_system_remove_volumes() {
  docker volume prune -af >/dev/null 2>&1
}

function doil_system_remove_user_doil_folders() {
  find /home -name .doil -type d -exec rm -rf {} +
}

function doil_system_remove_hosts_entry() {
  HOST=$(doil_get_conf "host=")
  sed -i "/172.24.0.254 ${HOST}/d" /etc/hosts
}

function doil_system_add_safe_git_dir() {
  git config --global --add safe.directory '/usr/local/share/doil/repositories/*'
  return 0
}

function doil_system_add_group() {
  CHECK_GROUP=$(grep doil /etc/group)
  if [[ -z ${CHECK_GROUP} ]]
  then
    groupadd doil
  fi

  return 0
}

function doil_system_add_user_to_doil_group() {
  id -nG $SUDO_USER | grep -qw 'doil'
    if [[ $? -ne 0 ]]
      then
        usermod -a -G doil ${SUDO_USER}
      fi
    return 0
}

function doil_system_create_folder() {
  GLOBAL_INSTANCES_PATH=$(cat ${SCRIPT_DIR}/conf/doil.conf | grep "global_instances_path" | cut -d '=' -f 2-)
  if [ ! -d "${GLOBAL_INSTANCES_PATH}" ]
  then
    mkdir -p "${GLOBAL_INSTANCES_PATH}"
  fi

  if [ ! -d /etc/doil ]
  then
    mkdir /etc/doil/
  fi

  if [ ! -d /usr/local/lib/doil ]
  then
    mkdir /usr/local/lib/doil
  fi

  if [ ! -d /usr/local/lib/doil/server ]
  then
    mkdir /usr/local/lib/doil/server
  fi

  if [ ! -d /usr/local/share/doil/instances ]
  then
    mkdir -p /usr/local/share/doil/instances
  fi

  if [ ! -d /usr/local/share/doil/repositories ]
  then
    mkdir -p /usr/local/share/doil/repositories
  fi

  if [ ! -d /usr/local/share/doil/templates ]
  then
    mkdir /usr/local/share/doil/templates
  fi

  return 0
}

function doil_system_copy_doil() {
  enable_keycloak="$1"
  if [[ "$enable_keycloak" == true ]]
  then
    cp -r ${SCRIPT_DIR}/templates/keycloak /usr/local/lib/doil/server/
  else
    if [ -d /usr/local/lib/doil/server/keycloak ]
    then
      rm -rf /usr/local/lib/doil/server/keycloak
    fi
  fi

  cp ${SCRIPT_DIR}/doil.sh /usr/local/bin/doil
  cp -r ${SCRIPT_DIR}/templates/mail /usr/local/lib/doil/server/
  cp -r ${SCRIPT_DIR}/templates/proxy /usr/local/lib/doil/server/
  cp -r ${SCRIPT_DIR}/templates/salt /usr/local/lib/doil/server/
  cp -r ${SCRIPT_DIR}/templates/php /usr/local/lib/doil/server/
  cp -r ${SCRIPT_DIR}/templates/minion /usr/local/share/doil/templates
  cp -r ${SCRIPT_DIR}/templates/base /usr/local/share/doil/templates
  cp -r ${SCRIPT_DIR}/../app /usr/local/lib/doil
  cp -r ${SCRIPT_DIR}/stack /usr/local/share/doil

  return 0
}

function doil_system_setup_config() {

  cp ${SCRIPT_DIR}/conf/doil.conf /etc/doil/doil.conf

  if [ ! -f /etc/doil/repositories.json ]
  then
    touch /etc/doil/repositories.json
  fi

  if [ ! -f /etc/doil/user.json ]
  then
    touch /etc/doil/user.json
  fi

  # ilias repo
  echo '"a:1:{i:1;O:27:\"CaT\\Doil\\Commands\\Repo\\Repo\":3:{s:7:\"\u0000*\u0000name\";s:5:\"ilias\";s:6:\"\u0000*\u0000url\";s:44:\"https://github.com/ILIAS-eLearning/ILIAS.git\";s:9:\"\u0000*\u0000global\";b:1;}}"' > "/etc/doil/repositories.json"

  chown -R root:doil /etc/doil

  return 0
}

function doil_system_setup_ip() {

  IPEXIST=$(grep "172.24.0.254" /etc/hosts)
  if [[ -z ${IPEXIST} ]]
  then
    HOST=$(doil_get_conf "host=")
    printf "172.24.0.254 ${HOST}" >> "/etc/hosts"
  fi
  return 0
}

function doil_system_setup_access() {
  GLOBAL_INSTANCES_PATH=$(cat ${SCRIPT_DIR}/conf/doil.conf | grep "global_instances_path" | cut -d '=' -f 2-)

  chown -R root:doil "${GLOBAL_INSTANCES_PATH}"
  chown -R root:doil /usr/local/lib/doil
  chown -R root:doil /etc/doil
  chown -R root:doil /usr/local/share/doil
  chown root:doil /usr/local/bin/doil
  chown -R root:doil /var/log/doil/

  chmod g+w "${GLOBAL_INSTANCES_PATH}"
  chmod -R g+s "${GLOBAL_INSTANCES_PATH}"
  chmod g+w /etc/doil/repositories.json
  chmod g+w /etc/doil/user.json
  chmod -R g+w /etc/doil
  chmod -R g+s /etc/doil
  chmod -R g+w /usr/local/share/doil/templates
  chmod -R g+w /usr/local/share/doil/instances
  chmod -R g+s /usr/local/share/doil/instances
  chmod -R g+w /usr/local/share/doil/repositories
  chmod -R g+s /usr/local/share/doil/repositories
  chmod +x /usr/local/bin/doil
  chmod -R 777 /var/log/doil/

  return 0
}

function doil_system_setup_userconfig() {

  HOME=$(eval echo "~${SUDO_USER}")

  if [ ! -d ${HOME}/.doil/ ]
  then
    mkdir ${HOME}/.doil/
  fi

  if [ ! -d ${HOME}/.doil/config/ ]
  then
    mkdir ${HOME}/.doil/config/
  fi

  if [ ! -f ${HOME}/.doil/config/repositories.json ]
  then
    touch ${HOME}/.doil/config/repositories.json
  fi

  if [ ! -d ${HOME}/.doil/repositories ]
  then
    mkdir ${HOME}/.doil/repositories
  fi

  if [ ! -d ${HOME}/.doil/instances ]
  then
    mkdir ${HOME}/.doil/instances
  fi

  chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"

  USEREXISTS=$(grep "${SUDO_USER}" /etc/doil/user.json)
  if [[ -z ${USEREXISTS} ]]
  then
    echo '"a:1:{i:0;O:27:\"CaT\\Doil\\Commands\\User\\User\":1:{s:7:\"\u0000*\u0000name\";s:'${#SUDO_USER}':\"'${SUDO_USER}'\";}}"' >> "/etc/doil/user.json"
  fi

  return 0
}

function doil_system_setup_log() {
  if [[ ! -d /var/log/doil/ ]]
  then
    mkdir /var/log/doil/
  fi

  if [[ ! -d /var/log/doil/xdebug ]]
  then
    mkdir /var/log/doil/xdebug
  fi

  if [[ ! -f /var/log/doil/stream.log ]]
  then
    touch /var/log/doil/stream.log
  fi
}
function doil_system_delete_potential_composer_lock() {
  if [ -f /usr/local/lib/doil/app/composer.lock ]
  then
    rm -rf /usr/local/lib/doil/app/composer.lock
  fi
  return 0
}

function doil_system_build_php_image() {
  (docker buildx build -q -t doil_php:stable /usr/local/lib/doil/server/php) 2>&1 > /var/log/doil/stream.log
  docker run --rm -ti -v /home:/home -v /usr/local/lib/doil:/usr/local/lib/doil -e PHP_INI_SCAN_DIR=/srv/php/mods-available -w /usr/local/lib/doil/app --user $(id -u):$(id -g) doil_php:stable /usr/local/bin/composer -q -n install
}

function doil_system_install_saltserver() {
  cd /usr/local/lib/doil/server/salt
  BUILD=$(docker compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  docker commit doil_saltmain doil_saltmain:stable 2>&1 > /var/log/doil/stream.log
}

function doil_system_install_keycloakserver() {
  cd /usr/local/lib/doil/server/keycloak

  KEYCLOAK_HOSTNAME=$(printf '%s\n' "$(doil_get_conf keycloak_hostname)" | sed -e 's/[\/&]/\\&/g')
  KEYCLOAK_NEW_ADMIN_PASSWORD=$(doil_get_conf keycloak_new_admin_password)
  KEYCLOAK_OLD_ADMIN_PASSWORD=$(doil_get_conf keycloak_old_admin_password)
  # Please leave this in as an example for default user creation
  # KEYCLOAK_USR_PASSWORD=$(doil_get_conf keycloak_usr_password)
  KEYCLOAK_DB_USERNAME=$(doil_get_conf keycloak_db_username)
  KEYCLOAK_DB_PASSWORD=$(doil_get_conf keycloak_db_password)

  sed -i "s/%TPL_SERVER_HOSTNAME%/${KEYCLOAK_HOSTNAME}/g" "/usr/local/lib/doil/server/keycloak/conf/keycloak-startup.conf"
  sed -i "s/%TPL_DB_USERNAME%/${KEYCLOAK_DB_USERNAME}/g" "/usr/local/lib/doil/server/keycloak/conf/keycloak-startup.conf"
  sed -i "s/%TPL_DB_PASSWORD%/${KEYCLOAK_DB_PASSWORD}/g" "/usr/local/lib/doil/server/keycloak/conf/keycloak-startup.conf"

  sed -i "s/%TPL_DB_USERNAME%/${KEYCLOAK_DB_USERNAME}/g" "/usr/local/lib/doil/server/keycloak/conf/init.sql"
  sed -i "s/%TPL_DB_PASSWORD%/${KEYCLOAK_DB_PASSWORD}/g" "/usr/local/lib/doil/server/keycloak/conf/init.sql"

  sed -i "s/%TPL_NEW_ADMIN_PASSWORD%/${KEYCLOAK_NEW_ADMIN_PASSWORD}/g" "/usr/local/share/doil/stack/states/keycloak/keycloak/init.sls"
  sed -i "s/%TPL_OLD_ADMIN_PASSWORD%/${KEYCLOAK_OLD_ADMIN_PASSWORD}/g" "/usr/local/share/doil/stack/states/keycloak/keycloak/init.sls"
  # Please leave this in as an example for default user creation
  # sed -i "s/%TPL_USR_PASSWORD%/${KEYCLOAK_USR_PASSWORD}/g" "/usr/local/share/doil/stack/states/keycloak/keycloak/init.sls"

  BUILD=$(docker compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  sleep 120
  docker exec -i doil_saltmain bash -c "salt 'doil.keycloak' state.highstate saltenv=keycloak" 2>&1 > /var/log/doil/stream.log
  docker commit doil_keycloak doil_keycloak:stable 2>&1 > /var/log/doil/stream.log
  IDP_META=$(docker exec -i doil_saltmain bash -c "salt 'doil.keycloak' http.query http://localhost:8080/realms/master/protocol/saml/descriptor --out=raw | cut -d \"'\" -f6")
  sed -i "s|%TPL_IDP_META%|${IDP_META}|g" "/usr/local/share/doil/stack/states/enable-saml/saml/init.sls"
  sed -i "s|%TPL_KEYCLOAK_HOSTNAME%|${KEYCLOAK_HOSTNAME}|g" "/usr/local/share/doil/stack/states/enable-saml/saml/init.sls"
  sed -i "s/%TPL_ADMIN_PASSWORD%/${KEYCLOAK_NEW_ADMIN_PASSWORD}/g" "/usr/local/share/doil/stack/states/enable-saml/saml/init.sls"
  sed -i "s|%TPL_KEYCLOAK_HOSTNAME%|${KEYCLOAK_HOSTNAME}|g" "/usr/local/share/doil/stack/states/disable-saml/saml/init.sls"
  sed -i "s/%TPL_ADMIN_PASSWORD%/${KEYCLOAK_NEW_ADMIN_PASSWORD}/g" "/usr/local/share/doil/stack/states/disable-saml/saml/init.sls"
}

function doil_system_install_proxyserver() {
  cd /usr/local/lib/doil/server/proxy
  NAME=$(printf '%s\n' $(doil_get_conf host=) | sed -e 's/[\/&]/\\&/g')
  sed -i "s/%TPL_SERVER_NAME%/${NAME}/g" "/usr/local/lib/doil/server/proxy/conf/nginx/local.conf"
  BUILD=$(docker compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  sleep 20
  docker exec -i doil_saltmain bash -c "salt 'doil.proxy' state.highstate saltenv=proxyservices" 2>&1 > /var/log/doil/stream.log
  docker commit doil_proxy doil_proxy:stable 2>&1 > /var/log/doil/stream.log
}

function doil_system_install_mailserver() {
  cd /usr/local/lib/doil/server/mail
  BUILD=$(docker compose up -d 2>&1 > /var/log/doil/stream.log) 2>&1 > /var/log/doil/stream.log
  sleep 20
  docker exec -i doil_saltmain bash -c "salt 'doil.mail' state.highstate saltenv=mailservices" 2>&1 > /var/log/doil/stream.log
  PASSWORD=$(doil_get_conf mail_password)
  if [[ "${PASSWORD}" != "ilias" ]]
  then
    PASSWORD_HASH=$(docker exec -i doil_saltmain bash -c "salt \"doil.mail\" shadow.gen_password \"${PASSWORD}\" --out txt" | cut -d ' ' -f 2-)
    docker exec -i doil_saltmain bash -c "salt \"doil.mail\" grains.setval 'roundcube_password' '${PASSWORD_HASH}'" 2>&1 > /var/log/doil/stream.log
    docker exec -i doil_saltmain bash -c "salt \"doil.mail\" state.highstate saltenv=change-roundcube-password" 2>&1 > /var/log/doil/stream.log
  fi
  docker commit doil_mail doil_mail:stable 2>&1 > /var/log/doil/stream.log
}

function doil_system_chown_dot_docker() {
  HOME=$(eval echo "~${SUDO_USER}")

  if [[ -d "${HOME}/.docker" ]]
  then
    chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.docker"
    return 0
  fi

  return 255
}
