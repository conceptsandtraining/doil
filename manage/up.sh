#!/bin/bash

# Prepare git to ignore the file modes because these will change
git config core.fileMode false
find . -type d -name .git -print | sed 's/.git//' | xargs -I% sh -c "cd %;git config core.fileMode false"

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
