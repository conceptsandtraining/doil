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

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Starting instance"

  # Prepare git to ignore the file modes because these will change
  git config core.fileMode false
  find ./volumes/ilias -type d -name .git -print | sed 's/.git//' | xargs -I% sh -c "cd %;git config core.fileMode false"

  # Start the container
  docker-compose up -d

  # get the docker process
  DCFOLDER=${PWD##*/}
  MACHINE=$DCFOLDER"_web"
  DCPROC=$(docker ps | grep $MACHINE)
  DCPROCHASH=${DCPROC:0:12}

  # make the files write and readable
  docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/www/'
  docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/ilias/'

  # naaaaaaarf :/
  docker exec $DCPROCHASH bash -c 'chmod -R 777 /var/www/'
  docker exec $DCPROCHASH bash -c 'chmod -R 777 /var/ilias/'

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance started"
else
  # not implemented
  echo "Currently not implemented"
fi
