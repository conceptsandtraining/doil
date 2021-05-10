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
  doil system:deinstall - updates the saltstack

SYNOPSIS
  doil salt:deinstall

DESCRIPTION
  This command deinstalls doil completely from the system. That
  does not include the instances itself but all the configuration
  and cached data which was necessary to use doil. This includes:
  - the config files in ~/.doil
  - the library files in /usr/local/lib/doil
  - doil itself in /usr/local/bin/doil

EXAMPLE:
  doil salt:deinstall

OPTIONS
  -h|--help    displays this help message
EOF