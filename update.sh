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

################################
# Removing old version if needed
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Removing old version"

if [ -f "/usr/local/bin/doil" ]
then
  rm /usr/local/bin/doil
fi
if [ -d "/usr/local/lib/doil" ]
then
  rm -rf /usr/local/lib/doil/lib
fi

#########################
# Copying the doil system
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Copying the doil system"

# Move the base script to the /usr/local/bin folder and make it executeable
cp src/doil.sh /usr/local/bin/doil
chmod a+x /usr/local/bin/doil

# Move the script library to /usr/local/lib/doil
if [ ! -d "/usr/local/lib/doil" ]
then
  mkdir /usr/local/lib/doil
fi

# copy the files
cp -r src/lib /usr/local/lib/doil/lib
chmod -R a+x /usr/local/lib/doil/lib

rm -rf /usr/local/lib/doil/tpl/main
cp -r src/tpl/main /usr/local/lib/doil/tpl/main

rm -rf /usr/local/lib/doil/tpl/minion
cp -r src/tpl/minion /usr/local/lib/doil/tpl/minion

rm -rf /usr/local/lib/doil/tpl/proxy
cp -r src/tpl/proxy /usr/local/lib/doil/tpl/proxy
mkdir -p /usr/local/lib/doil/tpl/proxy/conf

chown -R ${SUDO_USER}:${SODU_USER} /usr/local/lib/doil

rm -rf /usr/local/lib/doil/tpl/stack
cp -r src/tpl/stack /usr/local/lib/doil/tpl/stack

doil system:salt restart

# send IP to hosts
echo "172.24.0.254 doil" >> "/etc/hosts"

#################
# Everything done
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Everything done"
