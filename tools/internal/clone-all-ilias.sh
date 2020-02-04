#!/bin/bash

# check arguments
if [ -z "$1" ]
then
	echo "No repo given. Aborting."
	exit
fi
REPO="$1"

if [ "$REPO" == "ilias" ]
then
  git clone git@github.com:ILIAS-eLearning/ILIAS.git ../templates/repos/ilias
fi

if [ "$REPO" == "catilias" ]
then
  git clone git@github.com:conceptsandtraining/ILIAS.git ../templates/repos/catilias
fi

if [ "$REPO" == "tms" ]
then
  git clone git@github.com:conceptsandtraining/TMS.git ../templates/repos/tms
fi
