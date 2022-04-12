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
  doil system:mail - manages the mail server

SYNOPSIS
  doil system:mail [command]

DESCRIPTION
  This section helps to manage the mail server. You can use some commands
  to troubleshoot and debug if you encounter problems with the mail
  server.

EXAMPLE:
  doil system:mail login

COMMANDS
  login   logs the user into the mail server
  start   starts the mail server
  stop    stops the mail server
  restart restarts the mail server

OPTIONS
  -q|--quiet no output will be displayed
EOF
