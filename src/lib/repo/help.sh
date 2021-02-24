#!/bin/bash

cat <<-EOF
NAME
  doil repo - manages the repositories

SYNOPSIS
  doil repo:[command]

DESCRIPTION
  This command manages the registered repositories in doil. You
  can add, remove, list and update the repositories. See
  doil repo:[command] help for more information

EXAMPLE:
  doil repo:update --name ilias

COMMANDS
  list   lists the registered repositories
  add    adds a repository
  remove removes a repository
  update updates a repository
EOF