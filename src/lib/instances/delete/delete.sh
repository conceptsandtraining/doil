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

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
POSITIONAL=()
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/delete/help.sh"
      exit
      ;;
    *)    # delete the instance
      INSTANCE=$1
      break
      ;;
	esac
done

CAD=$(pwd)  
LINKNAME="${HOME}/.doil/$INSTANCE"
if [ -h "${LINKNAME}" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Deleting instance"

  # set machine inactive
  cd ${LINKNAME}
  docker-compose down
  cd $CAD

  # remove directory
  the_path=$(readlink ${LINKNAME})
  sudo rm -rf $the_path

  # remove link
  rm -f "${HOME}/.doil/$INSTANCE"

  if [ -f "/usr/local/lib/doil/tpl/proxy/conf/sites/${INSTANCE}.conf" ]
  then
    rm "/usr/local/lib/doil/tpl/proxy/conf/sites/${INSTANCE}.conf"
  fi

  docker exec -ti saltmain bash -c "echo 'y' | salt-key -d ${INSTANCE}.local"

  # docker
  DELETE=$(docker rmi $(docker images "doil/${INSTANCE}" -a -q))

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance deleted"
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInstance not found!"
  echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
fi