#!/bin/bash

# get the proc
DIRNAME=${PWD##*/}
DCPROC=$(docker ps | grep $DIRNAME)
DCPROCHASH=${DCPROC:0:12}

# login
docker exec -t -i $DCPROCHASH /bin/bash
