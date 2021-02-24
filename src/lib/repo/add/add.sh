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
    -n|--name)
      NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--repo)
      REPOSITORY="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/repo/add/help.sh"
      exit
      ;;
    -v|--verbose)
      VERBOSE=YES
      shift # past argument
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil repo:add --help\033[0m for more information"
      exit 255
      ;;
	esac
done

# check parameter
if [[ -z "${NAME}" ]]
then
  read -p "Name the repository: " NAME
fi
if [ -z ${NAME} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tParameter --name not set!"
  echo -e "\tUse \033[1mdoil repo:add --help\033[0m for more information"
  exit 255
fi

# check if repo exists
LINE=$(sed -n -e "/^${NAME}=/p" "${HOME}/.doil/config/repos")
if [ ! -z ${LINE} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tRepository ${NAME} already exist!"
  echo -e "\tUse \033[1mdoil repo:list\033[0m to see all repositories!"
  exit 255
fi

# check repo
if [[ -z "${NAME}" ]]
then
  read -p "URL of the repository: " REPOSITORY
fi
if [ -z ${REPOSITORY} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tParameter --repo not set!"
  echo -e "\tUse \033[1mdoil repo:add --help\033[0m for more information"
  exit 255
fi

$(echo "${NAME}=${REPOSITORY}" >> "${HOME}/.doil/config/repos")
if [ -z ${VERBOSE} ]
then
  echo "Repository ${NAME} added."
fi