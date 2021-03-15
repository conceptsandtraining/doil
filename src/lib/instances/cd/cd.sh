#!/bin/bash

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
POSITIONAL=()
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/cd/help.sh"
      exit
      ;;
    *)    # set the instance
      INSTANCE=$1
      break
      ;;
	esac
done

if [ ! -z "${INSTANCE}" ]
then
  LINKNAME="${HOME}/.doil/${INSTANCE}"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    builtin cd ${TARGET} 2> /dev/null
    exec bash
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
    exit
  fi
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tPlease specify an instance in order to navigate there."
  exit
fi