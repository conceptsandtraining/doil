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
POSITION=1
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/pack/import/help.sh"
      exit
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    *)
      if (( ${POSITION} == 1 ))
      then
        INSTANCE=${key}
      fi
      if (( ${POSITION} == 2 ))
      then
        PACK=${key}
      fi
      POSITION=$((POSITION+1))
      shift
      ;;
	esac
done

if [[ -z "${INSTANCE}" ]]
then
  read -p "Name the instance you'd like to import to: " INSTANCE
fi
if [[ ${GLOBAL} == TRUE ]]
then
  LINKPATH="/usr/local/share/doil/instances/${INSTANCE}"
  FLAG="--global"
  SUFFIX="global"
else
  LINKPATH="${HOME}/.doil/instances/${INSTANCE}"
  FLAG=""
  SUFFIX="local"
fi
CREATE=FALSE
if [[ -z "${INSTANCE}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tName of the instance cannot be empty!"
  echo -e "\tsee \033[1mdoil pack:import --help\033[0m for more information"
  exit
elif [[ ${INSTANCE} == *['!'@#\$%^\&\(\)*_+]* ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInvalid characters! Only letters and numbers are allowed!"
  echo -e "\tsee \033[1mdoil pack:import --help\033[0m for more information"
  exit
elif [[ ! -h "${LINKPATH}" ]]
then
  read -p "Instance ${INSTANCE} does not exist. Do you want to create it? [Yn]: " CONFIRM
  if [[ ${CONFIRM} == "y" ]] ||
     [[ ${CONFIRM} == "Y" ]] ||
     [[ -z ${CONFIRM} ]]
  then
    CREATE=TRUE
  else
    doil_send_log "Import aborted"
    exit
  fi
fi

if [[ ! -f ${PACK} ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe package ${PACK} does not exist!"
  echo -e "\tsee \033[1mdoil pack:import --help\033[0m for more information"
  exit
fi

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

doil_send_log "Importing instance ${INSTANCE}"

# unpack
unzip ${PACK}

# PACKNAME
PACKNAME=${PACK%.zip}

if [[ ${CREATE} == TRUE ]]
then
  # read config
  source ${PWD}/${PACKNAME}/conf/doil.conf

  # create project
  doil_send_log "Creating instance ${INSTANCE}. This will take a while."

  doil repo:add --name "${INSTANCE}_import" --repo ${PROJECT_REPOSITORY_URL}
  REPOSITORY="${INSTANCE}_import"

  doil create -n ${INSTANCE} -r ${REPOSITORY} -b ${PROJECT_BRANCH} -p ${PROJECT_PHP_VERSION} ${FLAG}

  # reset linkpath because we created a new instance
  if [[ ${GLOBAL} == TRUE ]]
  then
    LINKPATH="/usr/local/share/doil/instances/${INSTANCE}"
    FLAG="--global"
    SUFFIX="global"
  else
    LINKPATH="${HOME}/.doil/instances/${INSTANCE}"
    FLAG=""
    SUFFIX="local"
  fi
fi

# set target
TARGET=$(readlink ${LINKPATH})

doil_send_log "Copying necessary files"

# stop the instance
doil down ${INSTANCE} ${FLAG} --quiet

# remove all the files
rm -rf ${TARGET}/volumes/data
rm -rf ${TARGET}/volumes/ilias/data
rm -rf ${TARGET}/volumes/ilias/ilias.ini.php

# import the files
mkdir -p ${TARGET}/volumes/ilias/data/
mkdir -p ${TARGET}/volumes/data/
cp -r ${PWD}/${PACKNAME}/var/www/html/ilias.ini.php ${TARGET}/volumes/ilias/ilias.ini.php
cp -r ${PWD}/${PACKNAME}/var/www/html/data ${TARGET}/volumes/ilias/
cp -r ${PWD}/${PACKNAME}/var/ilias/data/* ${TARGET}/volumes/data
cp -r ${PWD}/${PACKNAME}/var/ilias/ilias.sql ${TARGET}/volumes/data/ilias.sql

# start the instance
doil up ${INSTANCE} --quiet ${FLAG}
sleep 15
doil_send_log "Importing database"

# import database
if [[ -f "${TARGET}/README.md" ]]
then
  SQLPW=$(cat "${TARGET}/README.md" | grep MYSQL_PASSWORD | cut -d\   -f2)
else
  echo "Please enter your MySQL password: "
  read -s SQLPW
  echo "Ok"
fi

#touch ${TARGET}/volumes/data/mysql-client.conf
#echo "[client]" > ${TARGET}/volumes/data/mysql-client.conf
#echo "user=ilias" >> ${TARGET}/volumes/data/mysql-client.conf
#echo "password=${SQLPW}" >> ${TARGET}/volumes/data/mysql-client.conf

#docker exec -i ${INSTANCE}_${SUFFIX} bash -c '/etc/init.d/mariadb stop'
#docker exec -i ${INSTANCE}_${SUFFIX} bash -c 'chown -R mysql:mysql /var/lib/mysql'
#docker exec -i ${INSTANCE}_${SUFFIX} bash -c 'chown -R root:root /etc/mysql'
#docker exec -i ${INSTANCE}_${SUFFIX} bash -c "service mysql restart"

docker exec -i ${INSTANCE}_${SUFFIX} bash -c 'mysql -e "DROP DATABASE IF EXISTS ilias;"'
docker exec -i ${INSTANCE}_${SUFFIX} bash -c 'mysql -e "CREATE DATABASE ilias;"'
docker exec -i ${INSTANCE}_${SUFFIX} bash -c "mysql ilias < /var/ilias/data/ilias.sql"

CLIENT_FILE_LOCATION=$(find ${TARGET}/volumes/ilias/data/ -iname client.ini.php)
sed -i "s/pass =.*/pass = '${SQLPW}'/" ${CLIENT_FILE_LOCATION}

doil_send_log "Setting permissions"

# set access
#sudo chown -R ${USER}:${USER} ${TARGET}
#docker exec -i ${INSTANCE}_${SUFFIX} bash -c "chown -R mysql:mysql /var/lib/mysql"
#docker exec -i ${INSTANCE}_${SUFFIX} bash -c "service mysql restart"

doil down ${INSTANCE} --quiet ${FLAG}
doil up ${INSTANCE} --quiet ${FLAG}
sleep 5
doil apply ${INSTANCE} access --quiet ${FLAG}

doil_send_log "Cleanup"

rm -rf ${PWD}/${PACKNAME}
docker exec -i ${INSTANCE}_${SUFFIX} bash -c "rm /var/ilias/data/ilias.sql"

doil_send_log "Import of ${INSTANCE} done"