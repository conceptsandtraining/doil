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
      eval "/usr/local/lib/doil/lib/instances/repair/help.sh"
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
  echo "[$NOW] Rapairing instance"

  # Start the container
  docker-compose up -d

  # remove the current ip from the host file and add the new one
  DCFOLDER=${PWD##*/}
  DCHASH=$(doil_get_hash $DCFOLDER)
  DCIP=$(doil_get_data $DCHASH "ip")
  DCHOSTNAME=$(doil_get_data $DCHASH "hostname")
  DCDOMAIN=$(doil_get_data $DCHASH "domainname")

  # sends the repair commands to the salt main server
  CWD=$(pwd)
  PROJECT_CONFIG="${CWD}/conf/doil.conf"
  source ${PROJECT_CONFIG}

  # get the ILIAS version of this project
  # to apply the correct ILIAS state
  ILIAS_VERSION_FILE=$(cat -e ${CWD}/volumes/ilias/include/inc.ilias_version.php | grep "ILIAS_VERSION_NUMERIC")
  ILIAS_VERSION=${ILIAS_VERSION_FILE:33:1}

  DCMAIN=$(docker ps | grep "saltmain")
  DCMAINHASH=${DCMAIN:0:12}

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Applying states. This will take a while."

  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=base --state-output=terse"
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=dev --state-output=terse"
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=php${PROJECT_PHP_VERSION} --state-output=terse"
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=ilias --state-output=terse"
  if (( ${ILIAS_VERSION} == 6 ))
  then
    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=composer --state-output=terse"
  elif (( ${ILIAS_VERSION} > 6 ))
  then
    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=composer2 --state-output=terse"
  elif (( ${ILIAS_VERSION} < 6 ))
  then
    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${PROJECT_NAME}.local' state.highstate saltenv=composer54 --state-output=terse"
  fi

  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Instance repaired"
else
  LINKNAME="${HOME}/.doil/${INSTANCE}"
  if [ -h "${LINKNAME}" ]
  then
    TARGET=$(readlink ${LINKNAME})
    cd ${TARGET}
    eval "doil instances:repair"
  else
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tInstance not found!"
    echo -e "\tuse \033[1mdoil instances:list\033[0m to see current installed instances"
  fi
fi