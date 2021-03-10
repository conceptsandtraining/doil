#!/bin/bash

cat <<-EOF
NAME
  doil salt:set - sets the repository for the saltstack configuration

SYNOPSIS
  doil salt:set <--repo|-r <repository>>

DESCRIPTION
  This command ...

EXAMPLE:
  doil salt:set --repo git@github.com:ILIAS-eLearning/ILIAS.git

OPTIONS
  -r|--repo    sets the url of the repository
  -h|--help    displays this help message
EOF