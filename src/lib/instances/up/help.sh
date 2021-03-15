#!/bin/bash

cat <<-EOF
NAME
  doil instances:up - starts an instance

SYNOPSIS
  doil instances:up [instance]

ALIAS
  doil up

DESCRIPTION
  This command starts an instance. If [instance] not given
  doil will try to login the instance from the current
  active directory if doil can find a suitable configuration.

EXAMPLE:
  doil instances:up ilias

OPTIONS
  -h|--help       displays this help message
EOF