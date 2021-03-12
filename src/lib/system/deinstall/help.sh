#!/bin/bash

cat <<-EOF
NAME
  doil system:deinstall - updates the saltstack

SYNOPSIS
  doil salt:deinstall

DESCRIPTION
  This command deinstalls doil completely from the system. That
  does not include the instances itself but all the configuration
  and cached data which was necessary to use doil. This includes:
  - the config files in ~/.doil
  - the library files in /usr/local/lib/doil
  - doil itself in /usr/local/bin/doil

EXAMPLE:
  doil salt:deinstall

OPTIONS
  -h|--help    displays this help message
EOF