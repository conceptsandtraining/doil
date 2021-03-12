#!/bin/bash

cat <<-EOF
NAME
  doil salt - manages the saltstack

SYNOPSIS
  doil salt:[command]

DESCRIPTION
  This section helps to manage the saltstack. You can use some commands
  to troubleshoot and debug if you encounter problems with the main
  salt server.

EXAMPLE:
  doil salt:set --repo https://github.com/lauraquellmalz/sample-salt-configuration

COMMANDS
  login   logs the user into the main salt server
  prune   prunes the main salt server
  reset   resets the saltstack to the buildin saltstack
  restart restarts the salt main server
  set     sets the repository for the saltstack
  update  updates the saltstack if you are using a custom saltstack
EOF