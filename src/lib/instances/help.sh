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
  doil instances - manages the instances

SYNOPSIS
  doil instances:[command]

DESCRIPTION
  This section provides everything belonging to the management of
  the instances. Every command comes with its own help which you
  can access by adding --help|-h to it.

EXAMPLE:
  doil instances:list

COMMANDS
  cd     switches the active directory to the instances folder
  create creates an instance for ILIAS with a certain configuration
  delete deletes an instance completely
  login  logges into the running instance
  up     starts an instance
  down   stops an instance
  list   lists the instances
EOF