#!/bin/bash

# set the command to work with
CMD=$1

# if we don't have any command we load the help
if [ -z "$CMD" ] || [ "$CMD" == "help" ]
then
  .lib/help.sh
	exit
fi

# Check if the script can be found bail if not
if [ ! -f ".lib/$CMD.sh" ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tCan't find a suitable command."
  echo -e "\tUse \033[1mman doil\033[0m for a full list of implemented commands"
  exit
fi

# create
if [ "$CMD" == "create" ]
then
  .lib/create.sh
	exit
fi

# up
if [ "$CMD" == "up" ]
then
  .lib/up.sh $2
	exit
fi

# down
if [ "$CMD" == "down" ]
then
  .lib/down.sh $2
	exit
fi

# login
if [ "$CMD" == "login" ]
then
  .lib/login.sh $2
	exit
fi

# stop-all
if [ "$CMD" == "stop-all" ]
then
  .lib/stop-all.sh
	exit
fi

# instances
if [ "$CMD" == "instances" ]
then
  .lib/instances.sh
  exit
fi

# cd
if [ "$CMD" == "cd" ]
then
  .lib/cd.sh $2
  exit
fi
