#!/bin/bash

# Start the container
docker-compose up -d

# get the docker process
DCFOLDER=${PWD##*/}
DCPROC=$(docker ps | grep $DCFOLDER)
DCPROCHASH=${DCPROC:0:12}

# make the files write and readable
docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/www/'
docker exec $DCPROCHASH bash -c 'chown -R www-data:www-data /var/ilias/'
