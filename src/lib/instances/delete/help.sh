#!/bin/bash

cat <<-EOF
NAME
  doil instances:delete - deletes an instance

SYNOPSIS
  doil instances:delete <instance>

ALIAS
  doil delete

DESCRIPTION
  This command deletes an instance. It will remove everything
  belonging to the given instance including all its files,
  configuration and misc data

EXAMPLE:
  doil instances:delete ilias

OPTIONS
  -h|--help       displays this help message
EOF