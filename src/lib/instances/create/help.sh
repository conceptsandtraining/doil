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
  doil instances:create - creates an instance

SYNOPSIS
  doil instances:create
    [--name|-n <name>]
    [--repo|-r <repository>]
    [--branch|-b <branch>]
    [--phpversion|-p <php version>]
    [--target|-t <path to target folder>]

ALIAS
  doil create

DESCRIPTION
  This command creates an instance depending on the given
  parameters. If you donot specify any parameter you will
  be promted with a wizard.

EXAMPLE:
  doil instances:create
    --name ilias
    --repo ilias
    --branch release_6
    --phpversion 7.3

OPTIONS
  -n|--name       sets the name of the instance
  -r|--repo       sets the repository to use
  -b|--branch     sets the branch to use
  -p|--phpversion sets the php version
  -t|--target     optional: sets the target destination for the instance.
                  If the folder does not exist, it will be created
  -h|--help       displays this help message
  -q|--quiet      no output will be displayed
EOF