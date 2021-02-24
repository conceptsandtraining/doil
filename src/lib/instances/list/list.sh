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
      eval "/usr/local/lib/doil/lib/instances/list/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil instances:list --help\033[0m for more information"
      exit 255
      ;;
	esac
done

echo "Currently registered instances:"
LIST=$(ls "${HOME}/.doil/")

declare -a INSTANCES=(${LIST})
for LINE in "${INSTANCES[@]}"
do
  if [ "${LINE}" != "config" ] \
    && [ "${LINE}" != "help" ]
  then
    echo "${LINE}"
  fi
done