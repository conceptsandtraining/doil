# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and TMS (with all its plugins and skins).

## Initial Setup

1. In order to get these tools up and running you first need to check your docker permissions. For that simply execute `/tools/fix-docker-permissions.sh`.

## Usage

1. Execute the script `create-container.sh` inside of the tools-Folder and follow the steps.
2. Your project will be available at `http://projectname.local`
3. phpMyAdmin will be available at `http://pma.projectname.local`

## Included tools

This toolbox comes with three handy tools. Execute these scripts inside of your project folder

* `/manage/up.sh` starts a container
* `/manage/down.sh` stops a container
* `/manage/login.sh` logs you into the current container if it is running.
* `/manage/stop-all.sh` stops all container
* `/manage/prune-networks.sh` DONOT USE

## Outlook

* automatic installation of ILIAS and TMS
* add dummy data to blank installations
* sync client data
