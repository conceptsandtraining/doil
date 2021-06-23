#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/ilias-tool-doil
#
#                    .-.
#                   / /
#                  / |
#    |\     ._ ,-""  `.
#    | |,,_/  7        ;
#  `;=     ,=(     ,  /
#   |`q  q  ` |    \_,|
#  .=; <> _ ; /  ,/'/ |
# ';|\,j_ \;=\ ,/   `-'
#     `--'_|\  )
#    ,' | /  ;'
#   (,,/ (,,/      Thanks to Concepts and Training for supporting doil

if [ $1 == "up" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:up
  else
    doil instances:up $2
  fi
  exit
fi

if [ $1 == "down" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:down
  else
    doil instances:down $2
  fi
  exit
fi

if [ $1 == "create" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:create
  else
    shift
    doil instances:create $@
  fi
  exit
fi

if [ $1 == "delete" ] || [ $1 == "rm" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:delete
  else
    doil instances:delete $2
  fi
  exit
fi

if [ $1 == "login" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:login
  else
    doil instances:login $2
  fi
  exit
fi

if [ $1 == "cd" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:cd
  else
    doil instances:cd $2
  fi
  exit
fi

if [ $1 == "repair" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:repair
  else
    doil instances:repair $2
  fi
  exit
fi

if [ $1 == "update" ]
then
  if [ -z ${2:+x} ]
  then
    doil instances:update
  else
    doil instances:update $2
  fi
  exit
fi

if [ $1 == "list" ] || [ $1 == "ls" ]
then
  doil instances:list
  exit
fi

if [ $1 == "apply" ]
then
  doil instances:apply $@
  exit
fi