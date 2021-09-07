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
  doil instances:apply - applies a state to the instance

SYNOPSIS
  doil instances:apply <instance> <state>

ALIAS
  doil apply

DESCRIPTION
  doil apply is a command to apply states for the instances. This is
  useful for re-applying singlular states to your instance.

EXAMPLE:
  doil instances:apply ilias composer

OPTIONS
  -g|--global determines if an instance is global or not 
  -h|--help   displays this help message
  -q|--quiet  no output will be displayed
EOF