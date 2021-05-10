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

cat <<-EOF
NAME
  doil salt - manages the saltstack

SYNOPSIS
  doil salt:[command]

DESCRIPTION
  This section helps to manage the saltstack. You can use some commands
  to troubleshoot and debug if you encounter problems with the main
  salt server. Every command comes with its own help which you can
  access by adding --help|-h to it.

EXAMPLE:
  doil salt:set --repo https://github.com/lauraquellmalz/sample-salt-configuration

COMMANDS
  login   logs the user into the main salt server
  prune   prunes the main salt server
  reset   resets the saltstack to the buildin saltstack
  restart restarts the salt main server
  set     sets the repository for the saltstack
  update  updates the saltstack if you are using a custom saltstack
EOF