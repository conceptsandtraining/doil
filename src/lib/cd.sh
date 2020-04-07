#!/bin/bash

WHOAMI=$(whoami)
INSTANCE=$1
if [ ! -z "$INSTANCE" ]
then
  LINKNAME="/home/$WHOAMI/.doil/$INSTANCE"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink -f ${LINKNAME})
    builtin cd ${TARGET} 2> /dev/null
    exec bash
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances\033[0m to see current installed instances"
  fi
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tPlease specify an instance in order to navigate there."
fi
