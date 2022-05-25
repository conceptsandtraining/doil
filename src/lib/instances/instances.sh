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
source /usr/local/lib/doil/lib/include/helper.sh

# start mandatory services
/usr/local/bin/doil system:salt start --quiet
/usr/local/bin/doil system:proxy start --quiet
/usr/local/bin/doil system:mail start --quiet

# get the command
CMD=$(doil_get_command ${1})
shift # important

doil_maybe_display_help "instances" ${CMD}
doil_eval_command "instances" ${CMD} $@