# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and other ILIAS related software like cate.

## Setup

1. Download and unpack this repository wherever you want
2. Execute `sudo ./install.sh` in order to install doil (you can remove the downloaded folder afterwards)
3. Check `man doil` or `doil help` for available commands and further instructions

## Dependencies

doil tries to use as little 3rd party software as possible. However doil needs some software from other sources in order to function:

* docker
* docker-compose
* dialog (doil installs this by itself)

## Architecture

### local configuration


