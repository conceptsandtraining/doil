#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

if [[ "$EUID" -ne 0 ]]
then
  id -nG "$USER" | grep -qw "docker"
  DOCKER_GROUP=$?
  id -nG "$USER" | grep -qw "doil"
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
fi

php /usr/local/lib/doil/app/src/cli.php  $@

