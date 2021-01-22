#!/bin/bash

# set the doilpath
case "$(uname -s)" in
  Darwin)
  DOILPATH="/usr/local/lib/doil"
  ;;
  Linux)
  DOILPATH="/usr/lib/doil"
  ;;
  *)
    exit
  ;;
esac

# set the command to work with
CMD=$1

# get the helper
source "${DOILPATH}/helper.sh"
source "${DOILPATH}/completion.sh"

# version
if [ "${CMD}" == "version" ] || [ "${CMD}" == "--version" ] || [ "${CMD}" == "-v" ]
then
  eval "${DOILPATH}/version.sh"
  exit
fi

# if we don't have any command we load the help
if [ -z "${CMD}" ] || [ "${CMD}" == "help" ] || [ "${CMD}" == "--help" ] || [ "${CMD}" == "-h" ]
then
  eval "${DOILPATH}/help.sh"
	exit
fi

# Check if the script can be found bail if not
if [ ! -f "${DOILPATH}/${CMD}.sh" ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tCan't find a suitable command."
  echo -e "\tUse \033[1mman doil\033[0m for a full list of implemented commands"
  exit 255
fi

# create
if [ "${CMD}" == "create" ]
then
  eval "${DOILPATH}/create.sh"
	exit 1
fi

# delete
if [ "${CMD}" == "delete" ]
then
  eval "${DOILPATH}/delete.sh" $2
	exit 1
fi

# up
if [ "${CMD}" == "up" ]
then
  eval "${DOILPATH}/up.sh" $2
	exit 1
fi

# down
if [ "${CMD}" == "down" ]
then
  eval "${DOILPATH}/down.sh" $2
	exit 1
fi

# login
if [ "${CMD}" == "login" ]
then
  eval "${DOILPATH}/login.sh" $2
	exit 1
fi

# instances
if [ "${CMD}" == "instances" ]
then
  eval "${DOILPATH}/instances.sh"
  exit 1
fi

# cd
if [ "${CMD}" == "cd" ]
then
  eval "${DOILPATH}/cd.sh" $2
  exit 1
fi

# log
if [ "${CMD}" == "log" ]
then
  eval "${DOILPATH}/log.sh"
  exit 1
fi
