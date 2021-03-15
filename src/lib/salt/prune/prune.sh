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
      eval "/usr/local/lib/doil/lib/salt/prune/help.sh"
      exit
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil salt:prune --help\033[0m for more information"
      exit 255
      ;;
	esac
done

# start service
cd /usr/local/lib/doil/tpl/main
docker-compose down
docker-compose up -d

sleep 5

DCMAIN=$(docker ps | grep "saltmain")
DCMAINHASH=${DCMAIN:0:12}

docker exec -t -i ${DCMAINHASH} /bin/bash -c 'echo "y" | salt-key -D'

echo "Salt pruned and restarted"