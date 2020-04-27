#!/bin/bash

# get the docker process
DCFOLDER=${PWD##*/}
MACHINE=$DCFOLDER"_web"
DCPROC=$(docker ps | grep $MACHINE)
DCPROCHASH=${DCPROC:0:12}

# run the composer
docker exec -t $DCPROCHASH /var/www/composer-install.sh
