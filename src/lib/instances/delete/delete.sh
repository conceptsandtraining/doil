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
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/delete/help.sh"
      exit
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift
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

  read -p "Please confirm that you want to delete ${INSTANCE} [yN]: " CONFIRM
  if [[ ${CONFIRM} == "y" ]]
  then

    # Pipe output to null if needed
    if [[ ${QUIET} == TRUE ]]
    then
      exec >>/var/log/doil.log 2>&1
    fi

    doil_send_log "Deleting instance"

    # check saltmain
    doil system:salt start --quiet

    # check proxy server
    doil system:proxy start --quiet

    # set machine inactive
    doil down ${INSTANCE} --quiet

    # remove directory
    the_path=$(readlink ${LINKNAME})
    sudo rm -rf $the_path

    # remove link
    rm -f "${HOME}/.doil/$INSTANCE"

    # remove key
    docker exec -ti saltmain bash -c "echo 'y' | salt-key -d ${INSTANCE}.local"

    # remove proxy
    if [ -f "/usr/local/lib/doil/tpl/proxy/conf/sites/${INSTANCE}.conf" ]
    then
      rm "/usr/local/lib/doil/tpl/proxy/conf/sites/${INSTANCE}.conf"
    fi
    doil system:proxy reload --quiet

    # remove docker image
    docker rmi $(docker images "doil/${INSTANCE}" -a -q)

    doil_send_log "Instance deleted"
  fi
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInstance not found!"
  echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
fi