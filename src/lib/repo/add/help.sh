#!/bin/bash

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