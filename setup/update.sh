#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

# get the helper
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source ${SCRIPT_DIR}/checks.sh
source ${SCRIPT_DIR}/log.sh
source ${SCRIPT_DIR}/system.sh
source ${SCRIPT_DIR}/check_requirements.sh
source ${SCRIPT_DIR}/updates/update.sh
source ${SCRIPT_DIR}/helper.sh
source ${SCRIPT_DIR}/env.sh
source ${SCRIPT_DIR}/colors.sh

echo "This update will stop all running doil instances. Please ensure to save relevant files."
read -r -p "Do you want to continue update? [y/N] " RESPONSE
case "$RESPONSE" in
    [yY][eE][sS]|[yY])
        check_requirements update
        echo "Performing updates. This will take a while."
        # perform the update
        doil_perform_update
        echo "Update finished"
        ;;
    *)
        echo "Abort by user!"
        exit
        ;;
esac
