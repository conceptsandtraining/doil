#!/bin/bash

function doil_get_hash() {
  if [ -z "$1" ]
  then
    echo "No name of instance given, aborting"
    exit
  fi

  DCPROC=$(docker ps | grep $1)
  DCPROCHASH=${DCPROC:0:12}
  echo $DCPROCHASH
}

doil_get_data() {
  if [ -z "$1" ]
  then
    echo "No hash given, aborting"
    exit
  fi

  if [ -z "$2" ]
  then
    echo "No datatype given, aborting"
    exit
  fi

  case $2 in
    "ip")
      echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1)
      ;;
    "hostname")
      echo $(docker inspect -f '{{.Config.Hostname}}' $1)
      ;;
    "domainname")
      echo $(docker inspect -f '{{.Config.Domainname}}' $1)
      ;;
  esac
}
