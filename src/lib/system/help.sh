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
  doil system - manages the doil system

SYNOPSIS
  doil system:<command>

DESCRIPTION
  doil provides you with a simple way to create and manage
  development and testing environments for ILIAS. It will
  create and provision a docker container according to your
  requirements, pull the ILIAS version you want to use and even
  install it if possible. Every section and command comes with
  its own help which you can access by adding --help|-h to it.

EXAMPLE:
  doil system:proxy login

COMMANDS
  deinstall deinstalls doil
  version   shows the currently installed version 
  salt      manages the salt server
  proxy     manages the proxy server
  user      manages the doil user

EOF