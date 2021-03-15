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
      eval "/usr/local/lib/doil/lib/instances/login/help.sh"
      exit
      ;;
    *)    # sets the instance
      INSTANCE=$1
      break
      ;;
	esac
done

# set the instance to work with
if [ -z "$INSTANCE" ]
then
  # if the instance is empty we are working with the current directory

  # check if docker-compose.yml exists and bail if not
  if [ ! -f "docker-compose.yml" ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tCan't find a suitable configuration file in this directory"
    echo -e "\tAre you in the right directory?"
    echo -e "\n\tSupported filenames: docker-compose.yml"

    exit
  fi

  # get the proc
  DCFOLDER=${PWD##*/}
  DCPROCHASH=$(doil_get_hash $DCFOLDER)

  # check if instance is running, if not, start it
  if [ -z $DCPROCHASH ]; then
    docker-compose up -d

    DCFOLDER=${PWD##*/}
    DCPROCHASH=$(doil_get_hash $DCFOLDER)
  fi

  # login
  docker exec -t -i $DCPROCHASH /bin/bash -c "export TERM=xterm-color; exec bash"
else
  LINKNAME="${HOME}/.doil/$INSTANCE"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    cd ${TARGET}
    eval "doil login"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
  fi
fi
