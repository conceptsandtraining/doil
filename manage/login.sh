#!/bin/bash

# get the proc
DCFOLDER=${PWD##*/}
MACHINE=$DCFOLDER"_web"
DCPROC=$(docker ps | grep $MACHINE)
DCPROCHASH=${DCPROC:0:12}

# login
docker exec -t -i $DCPROCHASH /bin/bash
