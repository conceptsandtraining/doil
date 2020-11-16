#!/bin/bash

# set the command to work with
CMD=$1

# get the helper
source /usr/lib/doil/helper.sh

# if we don't have any command we load the help
if [ -z "$CMD" ] || [ "$CMD" == "help" ]
then
  /usr/lib/doil/help.sh
	exit
fi

# Check if the script can be found bail if not
if [ ! -f "/usr/lib/doil/$CMD.sh" ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tCan't find a suitable command."
  echo -e "\tUse \033[1mman doil\033[0m for a full list of implemented commands"
  exit
fi

# create
if [ "$CMD" == "create" ]
then
  /usr/lib/doil/create.sh
	exit
fi

# up
if [ "$CMD" == "up" ]
then
  /usr/lib/doil/up.sh $2
	exit
fi

# down
if [ "$CMD" == "down" ]
then
  /usr/lib/doil/down.sh $2
	exit
fi

# login
if [ "$CMD" == "login" ]
then
  /usr/lib/doil/login.sh $2
	exit
fi

# stop-all
if [ "$CMD" == "stop-all" ]
then
  /usr/lib/doil/stop-all.sh
	exit
fi

# instances
if [ "$CMD" == "instances" ]
then
  /usr/lib/doil/instances.sh
  exit
fi

# cd
if [ "$CMD" == "cd" ]
then
  /usr/lib/doil/cd.sh $2
  exit
fi
