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
    -r|--repo)
      REPOSITORY="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/salt/update/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil salt:update --help\033[0m for more information"
      exit 255
      ;;
	esac
done

cd /usr/local/lib/doil/tpl/stack
if [[ -d .git ]]
then
  git fetch origin
  git pull origin master
fi