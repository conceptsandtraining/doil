#!/bin/bash

cat <<-EOF
NAME
  doil instances:login - logges into the running instance

SYNOPSIS
  doil instances:login [instance]

ALIAS
  doil login

DESCRIPTION
  This command lets you log into the running docker container
  of your ILIAS instance. If [instance] not given
  doil will try to login the instance from the current active
  directory if doil can find a suitable configuration.

EXAMPLE:
  doil instances:login ilias

OPTIONS
  -h|--help       displays this help message
EOF