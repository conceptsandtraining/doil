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
  doil repo:add - adds a repository

SYNOPSIS
  doil repo:add [--name|-n <name>] [--repo|-r <repository>]

DESCRIPTION
  This command adds a repository to the doil configuration file to prepare the
  possibilty to use another repository within the create process of a new
  instance. Both parameters are mandatory

EXAMPLE:
  doil repo:add --name ilias --repo git@github.com:ILIAS-eLearning/ILIAS.git

OPTIONS
  -n|--name    sets the name of the repository
  -r|--repo    sets the url of the repository
  -h|--help    displays this help message
EOF