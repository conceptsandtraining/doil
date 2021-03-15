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
      eval "/usr/local/lib/doil/lib/instances/up/help.sh"
      exit
      ;;
    *)    # start the instance
      INSTANCE=$1
      break
      ;;
	esac
done

if [ -z "${INSTANCE}" ]
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

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Starting instance"

  # Start the container
  docker-compose up -d

  # remove the current ip from the host file and add the new one
  DCFOLDER=${PWD##*/}
  DCHASH=$(doil_get_hash $DCFOLDER)
  DCIP=$(doil_get_data $DCHASH "ip")
  DCHOSTNAME=$(doil_get_data $DCHASH "hostname")
  DCDOMAIN=$(doil_get_data $DCHASH "domainname")

  HOS="linux"
  if [ ${HOS} == "linux" ]
  then
    sudo sed -i "/${DCHOSTNAME}.${DCDOMAIN}$/d" /etc/hosts
  elif [ ${HOS} == "mac" ]
  then
    sudo sed -i  "" "/${DCHOSTNAME}.${DCDOMAIN}$/d" /etc/hosts
  fi
  sudo /bin/bash -c "echo \"$DCIP $DCHOSTNAME.$DCDOMAIN\" >> /etc/hosts"

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance started"
else
  LINKNAME="${HOME}/.doil/${INSTANCE}"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    cd ${TARGET}
    eval "doil instances:up"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
  fi
fi