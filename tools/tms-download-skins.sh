#!/bin/bash

# check arguments
if [ -z "$1" ]
then
	echo "Set the projectname"
	exit
fi
if [ -z "$2" ]
then
	echo "Set the branch"
	exit
fi

# set the config
CWD=$(pwd)
SKINPATH="$CWD/../instances/$1/volumes/skins"
SKIN="$2"
PREFIX="origin/"

if [ "$SKIN" == "all" ]
then
	# all branches
	mkdir "$SKINPATH/base54"
	git clone git@github.com:conceptsandtraining/ilias-skins54.git "$SKINPATH/base54"
	cd "$SKINPATH/base54"

	# walk the branches
	for BRANCH in $(git branch -r);
	do
		if [[ "origin/HEAD -> origin/base54" != *"$BRANCH"* ]]; then
			BASEBRANCH=${BRANCH#"$PREFIX"}
			cp -r . ../$BASEBRANCH
			cd ../$BASEBRANCH && git checkout $BASEBRANCH && cd ../base54
		fi
	done
else
	# single skin
	mkdir "$SKINPATH/$SKIN"
	git clone git@github.com:conceptsandtraining/ilias-skins54.git "$SKINPATH/$SKIN"
	cd "$SKINPATH/$SKIN" && git checkout $SKIN
fi
