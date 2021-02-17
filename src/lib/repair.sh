#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/ilias-tool-doil
#
#                    .-.
#                   / /
#                  / |
#    |\     ._ ,-""  `.
#    | |,,_/  7        ;
#  `;=     ,=(     ,  /
#   |`q  q  ` |    \_,|
#  .=; <> _ ; /  ,/'/ |
# ';|\,j_ \;=\ ,/   `-'
#     `--'_|\  )
#    ,' | /  ;'
#   (,,/ (,,/      Thanks to Concepts and Training for supporting doil
#
# Last revised 2021-02-16

# set the doilpath
case "$(uname -s)" in
  Darwin)
    HOS="mac"
    DOILPATH="/usr/local/lib/doil"
  ;;
  Linux)
    HOS="linux"
    DOILPATH="/usr/lib/doil"
  ;;
  *)
    exit
  ;;
esac
source "${DOILPATH}/helper.sh"

CWD=$(pwd)

# set the instance to work with
INSTANCE=$1
if [ -z "$INSTANCE" ]
then
  # if the instance is empty we are working with the current directory

  # check if docker-compose.yml exists and bail if not
  if [ ! -f "docker-compose.yml" ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tCan't find a suitable configuration file in this directory"
    echo -e "\tAre you in the right directory?"
    echo -e "\n\tSupported filenames: docker-compose.yml"

    exit
  fi

  # Apply the states
  echo -e "In order to repair your instance doil needs to know your setup."
  read -p "PHP VERSION: " PHPVERSION

  NOW=$(date +'%D.%M.%Y %I:%M:%S')
  echo "[${NOW}] Starting repair job for ${INSTANCE}"

  # goto main, start it
  cd "${DOILPATH}/tpl/main"
  docker-compose up -d
  cd $CWD

  # start this instance
  doil up

  NOW=$(date +'%D.%M.%Y %I:%M:%S')
  echo "[${NOW}] Apply states"

  DCFOLDER=${PWD##*/}
  DCHASH=$(doil_get_hash $DCFOLDER)
  DCIP=$(doil_get_data $DCHASH "ip")
  DCHOSTNAME=$(doil_get_data $DCHASH "hostname")
  DCDOMAIN=$(doil_get_data $DCHASH "domainname")

  DCMAIN=$(docker ps | grep "saltmain")
  DCMAINHASH=${DCMAIN:0:12}

  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${DCHOSTNAME}.local' state.highstate saltenv=base --state-output=terse"
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${DCHOSTNAME}.local' state.highstate saltenv=dev --state-output=terse"
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${DCHOSTNAME}.local' state.highstate saltenv=php${PHPVERSION} --state-output=terse"

  NOW=$(date +'%D.%M.%Y %I:%M:%S')
  echo "[${NOW}] Repair job done"
else
  LINKNAME="${HOME}/.doil/$INSTANCE"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink -f ${LINKNAME})
    cd ${TARGET}
    eval "${DOILPATH}/repair.sh"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances\033[0m to see current installed instances"
  fi
fi
