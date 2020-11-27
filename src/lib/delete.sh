#!/bin/bash

# set the instance to work with
CAD=$(pwd)
WHOAMI=$(whoami)
INSTANCE=$1
  
LINKNAME="/home/$WHOAMI/.doil/$INSTANCE"
if [ -h "${LINKNAME}" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Deleting instance"

  # set machine inactive
  cd $LINKNAME
  docker-compose down
  cd $CAD

  # remove directory
  the_path=$(realpath $LINKNAME)
  sudo rm -rf $the_path

  # remove link
  rm -f "/home/$WHOAMI/.doil/$INSTANCE"

  # remove entry from the hosts
  sudo sed -i "/${INSTANCE}.local$/d" /etc/hosts

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance deleted"
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInstance not found!"
  echo -e "\tuse \033[1mdoil instances\033[0m to see current installed instances"
fi
