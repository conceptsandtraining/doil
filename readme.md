# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and TMS (with all its plugins and skins).

## Initial Setup

1. In order to get these tools up and running you first need to check your docker permissions. For that simply execute `/tools/fix-docker-permissions.sh`.

...

## Usage

1. Execute the script `/tools/create-container.sh` and follow the steps.

...

## Included tools

This toolbox comes with three handy tools. Every generated container provides several scripts which will help you to manage the container itself.

### up.sh

Starts a container

### down.sh

Stops a container

### login.sh

Logs you into the current container if it is running.

## General information

...

## Outlook

* automatic execution of composer install after container creation
* automatic installation of ILIAS and TMS
* add dummy data to blank installations
* sync client data
