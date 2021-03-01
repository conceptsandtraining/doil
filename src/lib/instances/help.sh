#!/bin/bash

cat <<-EOF
NAME
  doil instances - manages the instances

SYNOPSIS
  doil instances:[command]

DESCRIPTION
  This section manages ...

EXAMPLE:
  doil instances:list - shows all currently registered instances

COMMANDS
  cd     switches the active directory to the instances folder
  create creates an instance for ILIAS with a certain configuration
  delete deletes an instance completely
  login  logges into the running instance
  up     starts an instance
  down   stops an instance
  list   lists the instances
  repair repairs an instance
EOF