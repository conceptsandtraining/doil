#!/bin/bash
cd ../src/skins

# clone base skin
git clone git@github.com:conceptsandtraining/ilias-skins54.git base54
cd base54
PREFIX="origin/"
for BRANCH in $(git branch -r);
do
	if [[ "origin/HEAD -> origin/base53" != *"$BRANCH"* ]]; then
        BASEBRANCH=${BRANCH#"$PREFIX"}
		git clone git@github.com:conceptsandtraining/ilias-skins54.git ../$BASEBRANCH
		cd ../$BASEBRANCH && git checkout $BASEBRANCH && cd ../base54
	fi
done
