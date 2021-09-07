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
  doil pack - exports and imports a doil packacge

SYNOPSIS
  doil pack:<command>

DESCRIPTION
  doil pack exports and imports instances which are created with doil.
  With doil pack:export you receive a .zip-file with all the important
  data needed to import that package into an existing or new instance
  of ILIAS. See doil pack:import --help and doil pack:export --help
  for more information.

EXAMPLE:
  doil pack:export ilias

COMMANDS
  export exports a doil instance
  import imports a doil instance

EOF