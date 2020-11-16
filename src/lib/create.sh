#!/bin/bash

source /usr/lib/doil/helper.sh

# Get the settings
CWD=$(pwd)
WHOAMI=$(whoami)
TEMPLATES="/usr/lib/doil/tpl"

# Check if the current directory is writeable
if [ ! -w `pwd` ]; then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe current directory is not writeable for you."
  echo -e "\tPlease head to a different directory."

  exit
fi

# Get all the needed information from the user
# set the project name
read -p "Name the instance for this container ILIAS installation: " projectname
if [ -z "$projectname" ]
then
  echo "You have to set a name for this instance! Aborting."
  exit 0
fi

# check if the name has not wanted
if [[ $projectname == *['!'@#\$%^\&*()_+]* ]]; then
	echo "You are using an invalid charackter! Only letters and numbers are allowed! Aborting."
	exit 0
fi

# check if the instance if it exists
LINKPATH="/home/$WHOAMI/.doil/$projectname"
if [ -h "${LINKPATH}" ]
then
  echo "${projectname} already exists! Aborting."
  exit 0
fi

# get the branch
read -p "Set the branch to checkout [Default: release_6]: " project_branch
if [ -z $project_branch ]
then
  project_branch="release_6"
fi

# we got all the information now we start to build the structure
# first we create the needed folders
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Creating basic folders"

FOLDERPATH="$CWD/$projectname"
mkdir -p "$FOLDERPATH/conf"
mkdir -p "$FOLDERPATH/volumes/db"
mkdir -p "$FOLDERPATH/volumes/index"
mkdir -p "$FOLDERPATH/volumes/data"
mkdir -p "$FOLDERPATH/volumes/logs/error"
mkdir -p "$FOLDERPATH/volumes/logs/apache"

# set the link
ln -s "$FOLDERPATH" "/home/$WHOAMI/.doil/$projectname"

# copy the files 
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Copying necessary files"

cp "/usr/lib/doil/tpl/minion/run-supervisor.sh" "$FOLDERPATH/conf/run-supervisor.sh"
cp "/usr/lib/doil/tpl/minion/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
cp "/usr/lib/doil/tpl/minion/Dockerfile" "$FOLDERPATH/Dockerfile"

# copy ilias
cd /usr/lib/doil/tpl/repo/ilias
git fetch origin
git checkout $project_branch
git pull origin $project_branch
cp -r "/usr/lib/doil/tpl/repo/ilias" "$FOLDERPATH/volumes/ilias"

# replace the templates vars
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Replacing temporary variables"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PROJECT_NAME%/$projectname/g"

# start the main salt server
cd /usr/lib/doil/tpl/main
docker-compose up -d

# start the minion
cd $FOLDERPATH
docker-compose up -d

# apply the states to the minion
DCPROC=$(docker ps | grep "saltmain")
DCPROCHASH=${DCPROC:0:12}
docker exec -t -i $DCPROCHASH /bin/bash -c "salt '*' state.apply --state-output=terse"

# go to the minion and save the machine
DCFOLDER=${PWD##*/}
DCHASH=$(doil_get_hash $DCFOLDER)
docker commit $DCHASH doil/$projectname:stable

# add ip to hosts
DCIP=$(doil_get_data $DCHASH "ip")
DCHOSTNAME=$(doil_get_data $DCHASH "hostname")
DCDOMAIN=$(doil_get_data $DCHASH "domainname")
sudo /bin/bash -c "echo \"$DCIP $DCHOSTNAME.$DCDOMAIN\" >> /etc/hosts"

# Goodbye txt
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Everything done."
echo "See README.md inside of your instance folder in $FOLDERPATH for more information about passwords and IPs"
echo " "
echo "\\//. life long and prosper"
