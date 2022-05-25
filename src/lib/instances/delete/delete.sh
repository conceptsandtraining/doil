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

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

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
    -y|--yes)
      CONFIRM="y"
      shift
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    *)    # delete the instance
      INSTANCE=$1
      shift
      ;;
	esac
done

CAD=$(pwd)  
if [[ ${GLOBAL} == TRUE ]]
then
  LINKNAME="/usr/local/share/doil/instances/${INSTANCE}"
else
  LINKNAME="${HOME}/.doil/instances/${INSTANCE}"
fi
if [ -h "${LINKNAME}" ]
then

  if [[ -z ${CONFIRM} ]]
  then
    read -p "Please confirm that you want to delete ${INSTANCE} [yN]: " CONFIRM
  fi

  if [[ ${CONFIRM} == "y" ]]
  then

    # Pipe output to null if needed
    if [[ ${QUIET} == TRUE ]]
    then
      exec >>/var/log/doil.log 2>&1
    fi

    if [[ ${GLOBAL} == TRUE ]]
    then
      SUFFIX="global"
      FLAG="--global"
    else
      SUFFIX="local"
      FLAG=""
    fi

    doil_send_log "Deleting instance"

    # start machine for some adjustments
    /usr/local/bin/doil up ${INSTANCE} --quiet ${FLAG}
    THE_USER=$(id -u ${USER})
    THE_GROUP=$(id -g ${USER})
    docker exec -i ${INSTANCE}_${SUFFIX} bash -c "chown -R ${THE_USER}:${THE_GROUP} /var/lib/mysql"
    docker exec -i ${INSTANCE}_${SUFFIX} bash -c "chown -R ${THE_USER}:${THE_GROUP} /etc/mysql"
    docker exec -i ${INSTANCE}_${SUFFIX} bash -c "chown -R ${THE_USER}:${THE_GROUP} /etc/php"

    # set machine inactive
    /usr/local/bin/doil down ${INSTANCE} --quiet ${FLAG}

    # remove directory
    the_path=$(readlink ${LINKNAME})
    rm -rf $the_path

    # remove link
    if [[ ${GLOBAL} == TRUE ]]
    then
      rm -f "/usr/local/share/doil/instances/${INSTANCE}"
    else
      rm -f "${HOME}/.doil/instances/${INSTANCE}"
    fi

    # remove key
    docker exec -i doil_saltmain bash -c "echo 'y' | salt-key -d ${INSTANCE}.${SUFFIX}"

    # remove proxy
    if [ -f "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf" ]
    then
      rm "/usr/local/lib/doil/server/proxy/conf/sites/${INSTANCE}_${SUFFIX}.conf"
    fi
    /usr/local/bin/doil system:proxy reload --quiet

    # remove docker image
    docker volume rm ${INSTANCE}_persistent
    docker rmi $(docker images "doil/${INSTANCE}_${SUFFIX}" -a -q)

    # delete mails
    docker exec -i doil_postfix -c "/root/delete-postbox-configuration.sh ${INSTANCE}"

    doil_send_log "Instance deleted"
  fi
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInstance not found!"
  echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
fi