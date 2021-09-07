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
  doil pack:export - exports an intance

SYNOPSIS
  doil pack:export <instance>

DESCRIPTION
  This command exports an instance to an archive with all
  the data needed for an import. The final archivename will be
  <instance>-doilpack.zip. You will be asked for some passwords.

EXAMPLE:
  doil pack:export ilias

OPTIONS
  -g|--global determines if the instance is global or not
  -h|--help   displays this help message
  -q|--quiet  no output will be displayed
EOF