#!/bin/bash

cat <<-EOF
NAME
  doil repo:update - updates a repository

SYNOPSIS
  doil repo:update

DESCRIPTION
  This command updates a local repository so that it won't be
  fetched when an instances is created

EXAMPLE:
  doil repo:update ilias

OPTIONS
  -v|--verbose be verbose
  -h|--help    displays this help message
EOF