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
  doil system:proxy - manages the proxy server

SYNOPSIS
  doil system:proxy [command]

DESCRIPTION
  This section helps to manage the proxy server. You can use some commands
  to troubleshoot and debug if you encounter problems with the proxy
  server.

EXAMPLE:
  doil system:proxy login

COMMANDS
  login   logs the user into the proxy server
  prune   removes the configuration of the proxy server
  start   starts the proxy server
  stop    stops the proxy server
  restart restarts the proxy server
  reload  reloads the configuration

OPTIONS
  -q|--quiet no output will be displayed
EOF