#!/bin/bash

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

# set the network for the server
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Setting up network."

LINES=$(ls -l "/home/$WHOAMI/.doil/" | wc -l)
LINES=$(($LINES + 2))

SUB_NET_BASE="172.100.0.$LINES"
echo "### $projectname start" | sudo tee -a /etc/hosts > /dev/null
echo "$SUB_NET_BASE $projectname.local" | sudo tee -a /etc/hosts > /dev/null
echo "### $projectname end" | sudo tee -a /etc/hosts > /dev/null

# replace the templates vars for port and phpversion
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Replacing temporary variables"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PROJECT_NAME%/$projectname/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUB_NET_BASE%/$SUB_NET_BASE/g"

# Goodbye txt
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Everything done."
echo "See README.md inside of your instance folder in $FOLDERPATH for more information about passwords and IPs"
echo " "
echo "\\//. life long and prosper"
