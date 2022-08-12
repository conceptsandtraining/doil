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

# set doil pathes
DOILLIBPATH="/usr/local/lib/doil"

# set the host
case "$(uname -s)" in
  Darwin)
    HOST="mac"
    ;;
  Linux)
    HOST="linux"
    ;;
  *)
    exit
    ;;
esac