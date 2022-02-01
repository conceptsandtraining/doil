#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

COM=""
case ${1} in
  up|down|create|delete|login|cd|list|apply)
    COM=${1} # set command
    ;;
  rm)
    COM="delete" # set command
    ;;
  ls)
    COM="list" # set command
    ;;
  ps)
    COM="processstatus" # set command
    ;;
esac

if [[ ! -z ${COM} ]]
then
  shift # shift parameter
  doil instances:${COM} $@
  exit
fi