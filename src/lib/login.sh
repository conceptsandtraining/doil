#!/bin/bash

# set the instance to work with
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
  MACHINE=$DCFOLDER"_web"
  DCPROC=$(docker ps | grep $MACHINE)
  DCPROCHASH=${DCPROC:0:12}

  # login
  docker exec -t -i $DCPROCHASH /bin/bash
else
  # not implemented
  echo "Currently not implemented"
fi
