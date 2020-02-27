#!/bin/bash

# Prepare git to ignore the file modes because these will change
git config core.fileMode false

# Start the container
docker-compose up -d

# get the docker process
DCFOLDER=${PWD##*/}
MACHINE=$DCFOLDER"_web"
DCPROC=$(docker ps | grep $MACHINE)
DCPROCHASH=${DCPROC:0:12}

# run the composer
docker exec -t $DCPROCHASH /var/www/composer-install.sh

# make the files write and readable
docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/www/'
docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/ilias/'

# naaaaaaarf :/
docker exec $DCPROCHASH bash -c 'chmod -R 777 /var/www/'
docker exec $DCPROCHASH bash -c 'chmod -R 777 /var/ilias/'
