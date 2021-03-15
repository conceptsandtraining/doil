#!/bin/bash

cat <<-EOF
NAME
  doil salt:prune - prunes the salt master server

SYNOPSIS
  doil salt:prune

DESCRIPTION
  This commands prunes the salt master server by deleting
  currently accepted keys and reading the configuration.

EXAMPLE:
  doil salt:prune

OPTIONS
  -h|--help displays this help message
EOF