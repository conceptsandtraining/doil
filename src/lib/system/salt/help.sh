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

cat <<-EOF
NAME
  doil system:salt - manages the saltstack

SYNOPSIS
  doil system:salt [command]

DESCRIPTION
  This section helps to manage the saltstack. You can use some commands
  to troubleshoot and debug if you encounter problems with the main
  salt server.

EXAMPLE:
  doil system:salt login

COMMANDS
  login   logs the user into the main salt server
  prune   prunes the main salt server
  start   starts the salt main server
  stop    stops the salt main server
  restart restarts the salt main server
  states  lists the current available states
EOF