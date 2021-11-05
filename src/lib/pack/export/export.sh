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

# we need to move the pointer two positions
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -q|--quiet)
      QUIET=TRUE
      shift
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/pack/export/help.sh"
      exit
      ;;
    *)
      INSTANCE=${key}
      shift
      ;;
	esac
done

if [[ -z "${INSTANCE}" ]]
then
  read -p "Name the instance you'd like to apply a state on: " INSTANCE
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
if [[ -z "${INSTANCE}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tName of the instance cannot be empty!"
  echo -e "\tsee \033[1mdoil pack:export --help\033[0m for more information"
  exit
elif [[ ${INSTANCE} == *['!'@#\$%^\&\(\)*_+]* ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInvalid characters! Only letters and numbers are allowed!"
  echo -e "\tsee \033[1mdoil pack:export --help\033[0m for more information"
  exit
elif [[ ! -h "${LINKPATH}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe instance ${INSTANCE} does not exist!"
  echo -e "\tsee \033[1mdoil pack:export --help\033[0m for more information"
  exit
fi

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

doil_send_log "Exporting instance ${INSTANCE}"

# we need the data so we have to startup the instance
doil up ${INSTANCE} --quiet ${FLAG}
sleep 5

# copy database
doil_send_log "Exporting database. Enter password of database."

TARGET=$(readlink ${LINKPATH})
if [[ -f "${TARGET}/README.md" ]]
then
  SQLPW=$(cat "${TARGET}/README.md" | grep MYSQL_PASSWORD | cut -d\   -f2)
else
  echo "Please enter your MySQL password: "
  read -s SQLPW
  echo "Ok"
fi

touch ${TARGET}/volumes/data/mysql-client.conf
echo "[client]" > ${TARGET}/volumes/data/mysql-client.conf
echo "user=ilias" >> ${TARGET}/volumes/data/mysql-client.conf
echo "password=${SQLPW}" >> ${TARGET}/volumes/data/mysql-client.conf
docker exec -ti ${INSTANCE}_${SUFFIX} bash -c "mysqldump --defaults-extra-file=/var/ilias/data/mysql-client.conf ilias > /var/ilias/ilias.sql"

# make a local directory where we are
if [[ -d "${INSTANCE}-doilpack" ]]
then
  rm -rf "${INSTANCE}-doilpack"
fi
mkdir "${INSTANCE}-doilpack"
mkdir -p "${INSTANCE}-doilpack/var"
mkdir -p "${INSTANCE}-doilpack/var/www/html"
mkdir -p "${INSTANCE}-doilpack/conf"

# copy data
doil_send_log "Export data"
docker cp ${INSTANCE}_${SUFFIX}:/var/ilias ${INSTANCE}-doilpack/var/
docker cp ${INSTANCE}_${SUFFIX}:/var/www/html/data ${INSTANCE}-doilpack/var/www/html
docker cp ${INSTANCE}_${SUFFIX}:/var/www/html/ilias.ini.php ${INSTANCE}-doilpack/var/www/html/ilias.ini.php

# export conf
doil_send_log "Export config"
cp -r "${TARGET}/conf/doil.conf" "${INSTANCE}-doilpack/conf/doil.conf"

# pack
doil_send_log "Packing data."
if [[ -f "${INSTANCE}-doilpack.zip" ]]
then
  rm "${INSTANCE}-doilpack.zip"
fi
zip -r "${INSTANCE}-doilpack.zip" "${INSTANCE}-doilpack"

# cleanup
rm -rf "${INSTANCE}-doilpack"
doil down ${INSTANCE} --quiet ${FLAG}

doil_send_log "Done"