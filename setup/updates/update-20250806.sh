#!/usr/bin/env bash

doil_update_20250806() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias/* /usr/local/share/doil/stack/states/ilias
  cp -r ${SCRIPT_DIR}/../setup/stack/states/autoinstall/* /usr/local/share/doil/stack/states/autoinstall

  for DIR in /home/$SUDO_USER/.doil/instances/*
  do
    WWW_LINE_NUMBER=$(/usr/bin/cat "${DIR}"/docker-compose.yml 2> /dev/null | grep -n /var/www/.ssh | cut -d ':' -f 1)
    ROOT_LINE_NUMBER=$(/usr/bin/cat "${DIR}"/docker-compose.yml 2> /dev/null | grep -n /root/.ssh | cut -d ':' -f 1)

    if [ "${WWW_LINE_NUMBER}" != "" ]
    then
      sed -i "$((WWW_LINE_NUMBER-2)),$((WWW_LINE_NUMBER))d" "${DIR}"/docker-compose.yml
    fi

    if [ "${ROOT_LINE_NUMBER}" != "" ]
    then
      sed -i "$((ROOT_LINE_NUMBER-2)),$((ROOT_LINE_NUMBER))d" "${DIR}"/docker-compose.yml
    fi
  done

  for DIR in $(doil_get_conf global_instances_path=)/*
  do
    WWW_LINE_NUMBER=$(/usr/bin/cat "${DIR}"/docker-compose.yml  2> /dev/null | grep -n /var/www/.ssh | cut -d ':' -f 1)
    ROOT_LINE_NUMBER=$(/usr/bin/cat "${DIR}"/docker-compose.yml 2> /dev/null | grep -n /root/.ssh | cut -d ':' -f 1)
    if [ "${WWW_LINE_NUMBER}" != "" ]
    then
      sed -i "$((WWW_LINE_NUMBER-2)),$((WWW_LINE_NUMBER))d" "${DIR}"/docker-compose.yml
    fi

    if [ "${ROOT_LINE_NUMBER}" != "" ]
    then
      sed -i "$((ROOT_LINE_NUMBER-2)),$((ROOT_LINE_NUMBER))d" "${DIR}"/docker-compose.yml
    fi
  done

  GIT_PRIVATE_SSH_KEY_PATH=$(doil_get_conf git_private_ssh_key_path=)
  if [ "${GIT_PRIVATE_SSH_KEY_PATH}" == "" ]
  then
    echo "Please ensure to set 'git_private_ssh_key_path' in '/etc/doil/doil.conf' properly!"
    exit 1
  fi
  GIT_PRIVATE_SSH_KEY="$(cat ${GIT_PRIVATE_SSH_KEY_PATH})"

  GIT_PUBLIC_SSH_KEY_PATH=$(doil_get_conf git_public_ssh_key_path=)
  if [ "${GIT_PUBLIC_SSH_KEY_PATH}" == "" ]
  then
    echo "Please ensure to set 'git_public_ssh_key_path' in '/etc/doil/doil.conf' properly!"
    exit 1
  fi
  GIT_PUBLIC_SSH_KEY="$(cat ${GIT_PUBLIC_SSH_KEY_PATH})"

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
          doil down ${NAME} ${GLOBAL} &> /dev/null
          sleep 15
          doil up ${NAME} ${GLOBAL} &> /dev/null
          sleep 5

          doil_status_send_message "Apply state ilias to ${NAME}"
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' state.highstate saltenv=ilias" &> /dev/null
          doil_status_okay

          doil_status_send_message "Deploy ssh keys to ${NAME}"
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"${GIT_PRIVATE_SSH_KEY}\" > /root/.ssh/doil_git'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"${GIT_PRIVATE_SSH_KEY}\" > /var/www/.ssh/doil_git'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"${GIT_PUBLIC_SSH_KEY}\" > /root/.ssh/doil_git.pub'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"${GIT_PUBLIC_SSH_KEY}\" > /var/www/.ssh/doil_git.pub'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"Host *github*\n\tIdentityFile ~/.ssh/doil_git\n\tIdentitiesOnly yes\" > /root/.ssh/config'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'echo \"Host *github*\n\tIdentityFile ~/.ssh/doil_git\n\tIdentitiesOnly yes\" > /var/www/.ssh/config'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'ssh-keyscan github.com > /root/.ssh/known_hosts'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'ssh-keyscan github.com > /var/www/.ssh/known_hosts'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'chmod 0400 /root/.ssh/doil_git /var/www/.ssh/doil_git'" &> /dev/null
          docker exec -it doil_saltmain /bin/bash -c "salt '${NAME}.${SUFFIX}' cmd.run 'chown -R 1000:1000 /var/www/.ssh'" &> /dev/null
          doil_status_okay

          doil_status_send_message "Commit image for ${NAME}"
          docker commit ${INSTANCE} doil/${INSTANCE}:stable &> /dev/null
          doil_status_okay

          docker stop ${INSTANCE} &> /dev/null
      done
    fi

  return $?
}