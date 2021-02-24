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
      eval "/usr/local/lib/doil/lib/repo/list/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil repo:list --help\033[0m for more information"
      exit 255
      ;;
	esac
done

echo "Currently registered repositories:"
while read line
do
  NAME="$(cut -d'=' -f1 <<<${line})"
  REPO="$(cut -d'=' -f2 <<<${line})"

  echo -e "\t${NAME} - ${REPO}"
done < "${HOME}/.doil/config/repos"