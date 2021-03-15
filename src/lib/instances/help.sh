#!/bin/bash

cat <<-EOF
NAME
  doil instances - manages the instances

SYNOPSIS
  doil instances:[command]

DESCRIPTION
  This section provides everything belonging to the management of
  the instances. Every command comes with its own help which you
  can access by adding --help|-h to it.

EXAMPLE:
  doil instances:list

COMMANDS
  cd     switches the active directory to the instances folder
  create creates an instance for ILIAS with a certain configuration
  delete deletes an instance completely
  login  logges into the running instance
  up     starts an instance
  down   stops an instance
  list   lists the instances
  repair repairs the system of an instance
  update updates the system of an instance
EOF