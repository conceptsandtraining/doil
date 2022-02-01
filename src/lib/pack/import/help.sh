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
  doil pack:import - imports an intance

SYNOPSIS
  doil pack:import <instance> <package>

DESCRIPTION
  With this command doil is able to import an archive of 
  doilpack into an ILIAS installation. If the installation is
  not present, it will be created with the properties of the
  configuration inside of the pack. If the instance is present
  all existing data will be overwritten by the new data.

EXAMPLE:
  doil pack:import ilias ilias-doilpack.zip

OPTIONS
  -g|--global determines if the instance is global or not
  -h|--help   displays this help message
  -q|--quiet  no output will be displayed
EOF