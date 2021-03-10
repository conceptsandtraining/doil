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
      eval "/usr/local/lib/doil/lib/salt/reset/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil salt:reset --help\033[0m for more information"
      exit 255
      ;;
	esac
done

rm ${HOME}/.doil/config/saltstack
touch ${HOME}/.doil/config/saltstack

rm -rf /usr/local/lib/doil/tpl/stack
cp -r /usr/local/lib/doil/tpl/main/stack /usr/local/lib/doil/tpl/stack

echo "saltstack resetted."