#!/bin/bash

cat <<-EOF
NAME
  doil instances:down - stops an instance

SYNOPSIS
  doil instances:down [instance]

ALIAS
  doil down

DESCRIPTION
  This command stops an instance. If [instance] not given
  doil will try to stop the instance from the current active
  directory if doil can find a suitable configuration.

EXAMPLE:
  doil instances:down ilias

OPTIONS
  -h|--help       displays this help message
EOF