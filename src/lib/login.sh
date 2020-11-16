#!/bin/bash

# set the instance to work with
WHOAMI=$(whoami)
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

  # get the proc
  DCFOLDER=${PWD##*/}
  DCPROCHASH=$(doil_get_hash $DCFOLDER)

	# check if instance is running, if not, start it
	if [ -z $DCPROCHASH ]; then
		docker-compose up -d

		DCFOLDER=${PWD##*/}
    DCPROCHASH=$(doil_get_hash $DCFOLDER)
	fi

  # login
  docker exec -t -i $DCPROCHASH /bin/bash -c "export TERM=xterm-color; exec bash"
else
  LINKNAME="/home/$WHOAMI/.doil/$INSTANCE"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink -f ${LINKNAME})
    cd ${TARGET}
    /usr/lib/doil/login.sh
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances\033[0m to see current installed instances"
  fi
fi
