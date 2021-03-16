#!/bin/bash

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

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
      eval "/usr/local/lib/doil/lib/instances/delete/help.sh"
      exit
      ;;
    *)    # delete the instance
      INSTANCE=$1
      break
      ;;
	esac
done

CAD=$(pwd)  
LINKNAME="${HOME}/.doil/$INSTANCE"
if [ -h "${LINKNAME}" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Deleting instance"

  # set machine inactive
  cd ${LINKNAME}
  docker-compose down
  cd $CAD

  # remove directory
  the_path=$(readlink ${LINKNAME})
  sudo rm -rf $the_path

  # remove link
  rm -f "${HOME}/.doil/$INSTANCE"

  # remove entry from the hosts
  if [ ${HOST} == "linux" ]; then
    sudo sed -i "/${INSTANCE}.local$/d" /etc/hosts
  fi

  # docker
  docker image rm doil/$INSTANCE

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance deleted"
else
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInstance not found!"
  echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
fi