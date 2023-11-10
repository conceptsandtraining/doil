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

doil_get_conf() {
  CONFIG=${1}
  VALUE=$(cat /etc/doil/doil.conf | grep ${CONFIG} | cut -d '=' -f 2-)
  echo ${VALUE}
}

# If -T or --no-term is selected, the docker command runs without
# a terminal. Useful for starting doil by cron.
if [[ $1 == "-T" || $1 == "--no-term" ]]
then
  TERMINAL="-i"
  shift;
else
  TERMINAL="-ti"
fi


MAP_USER=""
if [[ "$EUID" -ne 0 ]]
then
  id -nG "$EUID" | grep -qw "docker"
  DOCKER_GROUP=$?
  id -nG "$EUID" | grep -qw "doil"
  DOIL_GROUP=$?

  if [ ${DOCKER_GROUP} = 1 ]
  then
    echo "Please ensure that ${USER} is member of the docker group and try again!"
    exit
  fi

  if [ ${DOIL_GROUP} = 1 ]
  then
    echo "Please ensure that ${USER} is member of the doil group and try again!"
    exit
  fi
  MAP_USER="--user $(id -u):$(id -g)"
fi

GLOBAL_INSTANCES_PATH=$(doil_get_conf global_instances_path)
if [ -z $GLOBAL_INSTANCES_PATH ]
then
  GLOBAL_INSTANCES_PATH=""
else
  GLOBAL_INSTANCES_PATH="-v $GLOBAL_INSTANCES_PATH:$GLOBAL_INSTANCES_PATH"
fi

DOCKER_GRP_ID=$(cat /etc/group | grep "^docker:" | cut -d : -f3)
DOIL_GRP_ID=$(cat /etc/group | grep "^doil:" | cut -d : -f3)

docker run --rm "${TERMINAL}" \
  -v /home:/home \
  -v $(pwd):$(pwd) \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/local/lib/doil:/usr/local/lib/doil \
  -v /usr/local/share/doil:/usr/local/share/doil \
  -v /usr/local/bin:/usr/local/bin \
  -v /etc/doil:/etc/doil \
  -v /etc:/etc \
  -v /var/log:/var/log \
  -e  PHP_INI_SCAN_DIR=/srv/php/mods-available \
  -e  SUDO_UID="$SUDO_UID" \
  $GLOBAL_INSTANCES_PATH \
  -w $(pwd) \
  $MAP_USER \
  --group-add ${DOCKER_GRP_ID} \
  --group-add ${DOIL_GRP_ID} \
  doil_php:stable \
  /usr/bin/php7.4 -c /srv/php/php.ini /usr/local/lib/doil/app/src/cli.php "$@"