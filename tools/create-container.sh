#!/bin/bash

# set current folder
CWD=$(pwd)
TEMPLATES="$CWD/../templates"

# set the project name
read -p "Name the project for this container ILIAS installation: " projectname
if [ -z "$projectname" ]
then
  echo "You have to set a projectname! Aborting."
  exit 0
fi

FOLDERPATH="$CWD/../instances/$projectname"
if [ -d "${FOLDERPATH}" ]
then
    echo "${projectname} already exists! Aborting."
    exit 0
fi

# set php version, defaults to 7.2
read -p "Set the PHP version for this installation [default: 7.2]: " phpversion
if [ -z "$phpversion" ]
then
  phpversion="7.2"
fi

# set the installation type
read -p "Set the type of your installation [options: ilias, catilias or tms [default: ilias]]: " type
if [ -z "$type" ]
then
  type="ilias"
fi

# if we have a tms setup, ask which skins should be installed
if [ "$type" == "tms" ]
then
  read -p "Set the skin you want to install [options: all, branchname [default: base54]]: " skin
  if [ -z "$skin" ]
  then
    skin="base54"
  fi
fi

# set the branch
if [ "$type" == "tms" ]
then
  read -p "Select the branch of the installation [e.g. tms_5-4, trunk [default: tms_5-4]]: " branch
  if [ -z "$branch" ]
  then
    branch="tms_5-4"
  fi
else
  read -p "Select the branch of the installation [e.g. release_5-4, trunk [default: release_5-4]]: " branch
  if [ -z "$branch" ]
  then
    branch="release_5-4"
  fi
fi

# we got all the information now we start to build the structure
# first we create the needed folders
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Creating basic folders"
mkdir "$FOLDERPATH"
mkdir "$FOLDERPATH/conf"
mkdir "$FOLDERPATH/volumes"
mkdir "$FOLDERPATH/volumes/db"
mkdir "$FOLDERPATH/volumes/data"
mkdir "$FOLDERPATH/volumes/logs"
mkdir "$FOLDERPATH/volumes/logs/error"

# copy the template filesDockerFile
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Copying necessary files"
cp "$TEMPLATES/docker-configs/debconf.selections" "$FOLDERPATH/conf/debconf.selections"
cp "$TEMPLATES/docker-configs/run-lamp.sh" "$FOLDERPATH/conf/run-lamp.sh"
cp "$TEMPLATES/docker-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
cp "$TEMPLATES/docker-configs/composer-install.sh" "$FOLDERPATH/conf/composer-install.sh"

# copy the docker file
cp "$TEMPLATES/dockerfiles/Dockerfile$phpversion" "$FOLDERPATH/Dockerfile"

# Copy the TMS scripts
if [ "$type" == "tms" ]
then
  mkdir "$FOLDERPATH/volumes/skins"
  mkdir "$FOLDERPATH/volumes/plugins"
  cp "$TEMPLATES/tms-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
fi

# replace the templates vars for port and phpversion
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Replacing temporary variables"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PHPVERSION%/$phpversion/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_FOLDER%/$projectname/g"
if [ "$type" == "tms" ]
then
  skinname=$skin
  if [ "$skin" == "all" ]
  then
    skinname="base54"
  fi
  find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SKIN%/$skinname/g"
fi

# set the network for the server
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Setting up network."
SUB_NET_NAME="in-$projectname"
SUB_NET_NAME=${SUB_NET_NAME//-}

LINES=$(docker network ls | grep " " | wc -l)
LINES=$(($LINES + 1))
SUB_NET_BASE="172.$LINES.0"

find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_BASE%/$SUB_NET_BASE/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_NAME%/$SUB_NET_NAME/g"

# add project to hosts
PMA_ADDRESS="$SUB_NET_BASE.3"
IL_ADDRESS="$SUB_NET_BASE.4"

read -p "Do you want the network to be added automatically? Type YES or NO: " insert_network

if [ "$insert_network" == "YES" ]
then
  echo "### $projectname start" | sudo tee -a /etc/hosts > /dev/null
  echo "$IL_ADDRESS $projectname.local" | sudo tee -a /etc/hosts > /dev/null
  echo "$PMA_ADDRESS pma.$projectname.local" | sudo tee -a /etc/hosts > /dev/null
  echo "### $projectname end" | sudo tee -a /etc/hosts > /dev/null
fi

# clone ilias or tms
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Cloning ILIAS"
if [ "$type" == "ilias" ]
then
  if [ ! -d "${TEMPLATES}/repos/ilias/" ]
  then
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] ILIAS repository does not exist. Cloning ..."
    ./internal/clone-all-ilias.sh ilias
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] Finished cloning ILIAS"
  fi
  cp -r "$TEMPLATES/repos/ilias/" "$FOLDERPATH/volumes/"
fi

if [ "$type" == "catilias" ]
then
  if [ ! -d "${TEMPLATES}/repos/catilias/" ]
  then
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] CAT ILIAS repository does not exist. Cloning ..."
    ./internal/clone-all-ilias.sh catilias
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] Finished cloning CAT ILIAS"
  fi
  cp -r "$TEMPLATES/repos/catilias/" "$FOLDERPATH/volumes"
  mv "$FOLDERPATH/volumes/catilias" "$FOLDERPATH/volumes/ilias"
fi

if [ "$type" == "tms" ]
then
  if [ ! -d "${TEMPLATES}/repos/tms/" ]
  then
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] TMS repository does not exist. Cloning ..."
    ./internal/clone-all-ilias.sh tms
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[$NOW] Finished cloning TMS"
  fi
  cp -r "$TEMPLATES/repos/tms/" "$FOLDERPATH/volumes/"
  mv "$FOLDERPATH/volumes/tms" "$FOLDERPATH/volumes/ilias"
fi

# Checkout the setted branch
cd "$FOLDERPATH/volumes/ilias"
git fetch origin
git checkout $branch
git pull origin $branch
cd $CWD

# Start the TMS Scripts
if [ "$type" == "tms" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Cloning TMS skins"
  ./internal/tms-download-skins.sh $projectname $skin
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Cloning TMS plugins"
  ./internal/tms-download-plugins.sh $projectname
fi

# Run container the first time
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Initial start of the servers"
cd "$FOLDERPATH"
../../tools/internal/initial-up.sh

# Goodbye txt
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Everything done."
echo "You can reach your ILIAS installation at http://$projectname.local"
echo "phpMyAdmin can be reached via http://pma.$projectname.local"

if [ "$insert_network" != "YES" ]
then
  echo "You chosed not to add the hosts information to the /etc/hosts file. Add following lines to your host files:"
  echo " "
  echo "### $projectname start"
  echo "$IL_ADDRESS $projectname.local"
  echo "$PMA_ADDRESS pma.$projectname.local"
  echo "### $projectname end"
  echo " "
fi

echo "You can reach the MySQL server at $SUB_NET_BASE.2:3306"
echo "Hint: Use the scripts in ./manage/ only in the project folder"
echo " "
echo "\\//. live long and prosper"
