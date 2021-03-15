#!/bin/bash

cat <<-EOF
NAME
  doil instances:update - updates an instance

SYNOPSIS
  doil instances:update [instance]

ALIAS
  doil update

DESCRIPTION
  This command updates the system of an instance by its setted
  configuration. If [instance] not given doil will try to update
  the instance from the current active directory if doil can
  find a suitable configuration.

EXAMPLE:
  doil instances:repair ilias

OPTIONS
  -h|--help       displays this help message
EOF