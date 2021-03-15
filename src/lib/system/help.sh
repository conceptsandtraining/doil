#!/bin/bash

cat <<-EOF
NAME
  doil - ILIAS docker tool

SYNOPSIS
  doil <section>:<command>

DESCRIPTION
  doil provides you with a simple way to create and manage
  development and testing environments for ILIAS. It will
  create and provision a docker container according to your
  requirements, pull the ILIAS version you want to use and even
  install it if possible. Every section and command comes with
  its own help which you can access by adding --help|-h to it.

EXAMPLE:
  doil repo:update --name ilias

SECTIONS
  instances manages everything regarding to the instances
  repo      manages the repositories
  system    everything which affects the doil system itself
  salt      manages the salt master server

COMMANDS
  deinstall deinstalls the whole doil system
EOF