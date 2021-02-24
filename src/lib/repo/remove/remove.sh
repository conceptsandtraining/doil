#!/bin/bash

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/repo/remove/help.sh"
      exit
      ;;
    -v|--verbose)
      VERBOSE=YES
      shift # past argument
      ;;
    *)    # unknown option
      NAME=$1
      break
      ;;
	esac
done

# check parameter
if [ -z ${NAME} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tParameter --name not set!"
  echo -e "\tUse \033[1mdoil repo:remove --help\033[0m for more information"
  exit 255
fi

# check if repo exists
LINE=$(sed -n -e "/^${NAME}=/p" "${HOME}/.doil/config/repos")
if [ -z ${LINE} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tRepository ${NAME} does not exist!"
  echo -e "\tUse \033[1mdoil repo:list\033[0m to see all repositories!"
  exit 255
fi

$(sed -i "/${NAME}=/d" "${HOME}/.doil/config/repos")
rm -rf "/usr/local/lib/doil/tpl/repos/${NAME}"
if [ -z ${VERBOSE} ]
then
  echo "Repository ${NAME} removed."
fi