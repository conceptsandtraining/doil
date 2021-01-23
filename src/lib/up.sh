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
# Last revised 2021-mm-dd

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

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Starting instance"

  # Start the container
  docker-compose up -d

  # remove the current ip from the host file and add the new one
  DCFOLDER=${PWD##*/}
  DCHASH=$(doil_get_hash $DCFOLDER)
  DCIP=$(doil_get_data $DCHASH "ip")
  DCHOSTNAME=$(doil_get_data $DCHASH "hostname")
  DCDOMAIN=$(doil_get_data $DCHASH "domainname")

  if [ ${HOS} == "linux" ]; then
    sudo sed -i "/${DCHOSTNAME}.${DCDOMAIN}$/d" /etc/hosts
  elif [ ${HOS} == "mac" ]; then
    sudo sed -i  "" "/${DCHOSTNAME}.${DCDOMAIN}$/d" /etc/hosts
  fi
  sudo /bin/bash -c "echo \"$DCIP $DCHOSTNAME.$DCDOMAIN\" >> /etc/hosts"

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance started"
else
  LINKNAME="${HOME}/.doil/$INSTANCE"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink -f ${LINKNAME})
    cd ${TARGET}
    eval "${DOILPATH}/up.sh"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances\033[0m to see current installed instances"
  fi
fi
