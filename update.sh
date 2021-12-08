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

# sudo user check
if [ "$EUID" -ne 0 ]
then
  echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
  echo -e "\tPlease execute this script as sudo user!"
  exit
fi

CHECK_DOCKER=$(docker --version | tail -n 1 | cut -d " " -f 3 | cut -c 1-5)
vercomp () {
  if [[ $1 == $2 ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]
    then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]}))
    then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]}))
    then
      return 2
    fi
  done
  return 0
}

testvercomp () {
  vercomp $1 $2
  case $? in
    0) op='=';;
    1) op='>';;
    2) op='<';;
  esac
  if [[ $op != $3 ]]
  then
    echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
    echo -e "\tYour docker version is not supported!"
    echo -e "\tdoil requires at least docker version \033[1m19.03\033[0m. You have \033[1m${CHECK_DOCKER}\033[0m installed."
    exit
  fi
}
testvercomp ${CHECK_DOCKER} "19.02" ">"

# check the OS
OPS=""
case "$(uname -s)" in
  Darwin)
    OPS="mac"
	  ;;
  Linux)
    OPS="linux"
	  ;;
  *)
    echo -e "\033[1mREQUIREMENT ERROR:\033[0m"
    echo -e "\tYour operating system is not supported!"
    exit
    ;;
esac

# color support
GREEN='\033[0;32m'
NC='\033[0m'

################################
# Removing old version if needed
echo -n "Removing old version ..."

if [ -f "/usr/local/bin/doil" ]
then
  rm /usr/local/bin/doil
fi
if [ -d "/usr/local/lib/doil" ]
then
  rm -rf /usr/local/lib/doil/lib
fi

printf " ${GREEN}ok${NC}\n"

CHECK_GROUP=$(grep doil /etc/group)
if [[ -z ${CHECK_GROUP} ]]
then
  echo -n "Adding group doil ..."
  groupadd doil
  printf " ${GREEN}ok${NC}\n"
fi

# create the log file
if [ ! -f /var/log/doil.log ]
then
  echo -n "Creating log file in /var/log/doil.log ..."

  touch /var/log/doil.log
  chown root:doil /var/log/doil.log
  chmod 777 /var/log/doil.log

  printf " ${GREEN}ok${NC}\n"
fi

# create mandatory folders
echo -n "Creating mandatory folders ..."

if [ ! -d /usr/local/lib/doil ]
then
  mkdir /usr/local/lib/doil
fi
if [ ! -d /usr/local/lib/doil/lib ]
then
  mkdir /usr/local/lib/doil/lib
fi
if [ ! -d /usr/local/lib/doil/server ]
then
  mkdir /usr/local/lib/doil/server
fi
chown -R root:doil /usr/local/lib/doil

if [ ! -d /etc/doil ]
then
  mkdir /etc/doil/
  chown -R root:doil /etc/doil
  chmod -R g+w /etc/doil
  chmod -R g+s /etc/doil
fi

if [ ! -d /usr/local/share/doil ]
then
  mkdir /usr/local/share/doil
  chown -R root:doil /usr/local/share/doil
fi
if [ ! -d /usr/local/share/doil/templates ]
then
  mkdir /usr/local/share/doil/templates
fi
if [ ! -d /usr/local/share/doil/instances ]
then
  mkdir /usr/local/share/doil/instances
fi
if [ ! -d /usr/local/share/doil/instances ]
then
  mkdir /usr/local/share/doil/instances
  chmod -R g+w /usr/local/share/doil/instances
  chmod -R g+s /usr/local/share/doil/instances
fi
if [ ! -d /usr/local/share/doil/repositories ]
then
  mkdir /usr/local/share/doil/repositories
  chmod -R g+w /usr/local/share/doil/repositories
  chmod -R g+s /usr/local/share/doil/repositories
fi

printf " ${GREEN}ok${NC}\n"

# copy doil system
echo -n "Copy doil system ..."

cp src/doil.sh /usr/local/bin/doil
chown root:doil /usr/local/bin/doil
chmod +x /usr/local/bin/doil

cp -r src/lib/* /usr/local/lib/doil/lib/
chown -R root:doil /usr/local/lib/doil/lib
chmod -R +x /usr/local/lib/doil/lib

cp -r src/server/* /usr/local/lib/doil/server/
chown -R root:doil /usr/local/lib/doil/server
chmod -R 777 /usr/local/lib/doil/server/proxy/conf/

cp -r src/templates/* /usr/local/share/doil/templates
chown root:doil /usr/local/share/doil/templates

cp -r src/stack/* /usr/local/share/doil/stack
chown -R root:doil /usr/local/share/doil/stack

printf " ${GREEN}ok${NC}\n"

# setting up basic configuration
echo -n "Setting up basic configuration ..."

if [ ! -f /etc/doil/doil.conf ]
then
  cp src/conf/doil.conf /etc/doil/doil.conf
fi

if [ ! -f /etc/doil/repositories.conf ]
then
  touch /etc/doil/repositories.conf
  chmod g+w /etc/doil/repositories.conf
fi

if [ ! -f /etc/doil/user.conf ]
then
  touch /etc/doil/user.conf
  chmod g+w /etc/doil/user.conf
fi
chown -R root:doil /etc/doil/

IPEXIST=$(grep "172.24.0.254" /etc/hosts)
if [[ -z ${IPEXIST} ]]
then
  echo "172.24.0.254 doil" >> "/etc/hosts"
fi

printf " ${GREEN}ok${NC}\n"

echo -n "Move userdata ..."

HOME=$(eval echo "~${SUDO_USER}")
if [ ! -f ${HOME}/.doil/config/repositories.conf ]
then
  mv ${HOME}/.doil/config/repos ${HOME}/.doil/config/repositories.conf
fi

if [ ! -d ${HOME}/.doil/repositories ]
then
  mkdir ${HOME}/.doil/repositories
  mv /usr/local/lib/doil/tpl/repos ${HOME}/.doil/repositories
fi

if [ ! -d ${HOME}/.doil/instances ]
then
  mkdir ${HOME}/.doil/instances
  for LINK in $(ls ${HOME}/.doil)
  do
    if [[ ${LINK} == "config" ]]
    then
      continue
    fi
    mv ${LINK} ${HOME}/.doil/instances/${LINK}
  done
fi

chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"
usermod -a -G doil ${SUDO_USER}
echo "${SUDO_USER}">>"/etc/doil/user.conf"

printf " ${GREEN}ok${NC}\n"

echo -n "Cleanup ..."

rm -rf /usr/local/lib/doil/tpl/

printf " ${GREEN}ok${NC}\n"

echo -n "Restarting server ..."

doil system:proxy restart --quiet
doil system:salt restart --quiet

printf " ${GREEN}ok${NC}\n"

#################
# Everything done
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Everything done"
