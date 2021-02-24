#!/bin/bash

cat <<-EOF
NAME
  doil instances:create - creates an instance

SYNOPSIS
  doil instances:create \
    <--name|-n <name>> \
    <--repo|-r <repository>> \
    <--branch|-b <branch>> \
    <--phpversion|-p <php version>> \
    [--target|-t <path to target folder>]

DESCRIPTION
  This command creates an instance ...

EXAMPLE:
  doil instances:create --name ilias \
    --repo ilias \
    --branch release_6 \
    --phpversion 7.3

OPTIONS
  -n|--name       sets the name of the instance
  -r|--repo       sets the repository to use
  -b|--branch     sets the branch to use
  -p|--phpversion sets the php version
  -t|--target     optional: sets the target destination for the instance.
                  If the folder does not exist, it will be created
  -v|--verbose    be verbose
  -h|--help       displays this help message
EOF