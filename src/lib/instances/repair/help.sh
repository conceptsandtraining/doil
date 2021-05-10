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
  doil instances:repair - repairs an instance

SYNOPSIS
  doil instances:repair [instance]

ALIAS
  doil repair

DESCRIPTION
  This command repairs the system of an instance by its setted
  configuration. If [instance] not given doil will try to repair
  the instance from the current active directory if doil can
  find a suitable configuration.

EXAMPLE:
  doil instances:repair ilias

OPTIONS
  -h|--help       displays this help message
EOF