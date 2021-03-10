#!/bin/bash

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/helper.sh

# set current ad
CWD=$(pwd)

# we can move the pointer one position
shift

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/salt/restart/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil salt:restart --help\033[0m for more information"
      exit 255
      ;;
	esac
done

##############################
# starting master salt service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Restarting master salt service"

# start service
cd /usr/local/lib/doil/tpl/main
docker-compose down
docker-compose up -d

##############################
# checking master salt service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Checking master salt service"

# check if the salt-master service is running the service
DCMAIN=$(docker ps | grep "saltmain")
DCMAINHASH=${DCMAIN:0:12}
docker exec -ti ${DCMAINHASH} bash -c "salt-master -d"
