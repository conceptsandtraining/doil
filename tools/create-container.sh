#!/bin/bash

# Set the config. You might adjust the urls
ILIAS_URL_SSH="git@github.com:ILIAS-eLearning/ILIAS.git"
TMS_URL_SSH="git@github.com:conceptsandtraining/TMS.git"
CATILIAS_URL_SSH="git@github.com:conceptsandtraining/ILIAS.git"

# set current folder
CWD=$(pwd)
TEMPLATES="$CWD/../templates"

# set the project name
read -p "Name the project for this container ILIAS installation: " projectname
if [ -z "$projectname" ]
then
  echo "You have to set a projectname! Aborting."
  exit 1
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
read -p "Select the branch of the installation [e.g. release_5-4, trunk [default: release_5-4]]: " branch
if [ -z "$branch" ]
then
  branch="release_5-4"
fi

#read -p "Do you want to do an automatic installation? [Type YES or NO in uppercase]: " autoinstall

# we got all the information now we start to build the structure
# first we create the needed folders
FOLDERPATH="$CWD/../instances/$projectname"
mkdir "$FOLDERPATH"
mkdir "$FOLDERPATH/conf"
mkdir "$FOLDERPATH/volumes"
mkdir "$FOLDERPATH/volumes/db"
mkdir "$FOLDERPATH/volumes/ilias"
mkdir "$FOLDERPATH/volumes/data"
mkdir "$FOLDERPATH/volumes/logs"
mkdir "$FOLDERPATH/volumes/logs/error"

# copy the template filesDockerFile
cp "$TEMPLATES/docker-configs/debconf.selections" "$FOLDERPATH/conf/debconf.selections"
cp "$TEMPLATES/docker-configs/run-lamp.sh" "$FOLDERPATH/conf/run-lamp.sh"
cp "$TEMPLATES/docker-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
cp "$TEMPLATES/ilias-configs/composer-install.sh" "$FOLDERPATH/conf/composer-install.sh"

# Copy the TMS scripts
if [ "$type" == "tms" ]
then
  mkdir "$FOLDERPATH/volumes/skins"
  mkdir "$FOLDERPATH/volumes/plugins"
  cp "$TEMPLATES/tms-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
fi

# replace the templates vars for port and phpversion
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
SUB_NET_NAME="in-$projectname"
SUB_NET_NAME=${SUB_NET_NAME//-}

LINES=$(docker network ls | grep " " | wc -l)
SUB_NET_BASE="172.100.$LINES"

find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_BASE%/$SUB_NET_BASE/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_NAME%/$SUB_NET_NAME/g"

# add project to hosts
PMA_ADDRESS="$SUB_NET_BASE.3"
IL_ADDRESS="$SUB_NET_BASE.4"

echo "$IL_ADDRESS $projectname.local" | sudo tee -a /etc/hosts > /dev/null
echo "$PMA_ADDRESS pma.$projectname.local" | sudo tee -a /etc/hosts > /dev/null

# clone ilias or tms
#if [ "$type" == "ilias" ]
#then
#  git clone $ILIAS_URL_SSH "$FOLDERPATH/volumes/ilias"
#fi

if [ "$type" == "catilias" ]
then
  git clone $CATILIAS_URL_SSH "$FOLDERPATH/volumes/ilias"
fi

if [ "$type" == "tms" ]
then
  git clone $TMS_URL_SSH "$FOLDERPATH/volumes/ilias"
fi

# Start the TMS Scripts
if [ "$type" == "tms" ]
then
  ./tms-download-skins.sh $projectname $skin
  ./tms-download-plugins.sh $projectname
fi

# Checkout the setted branch
#cd "$FOLDERPATH/volumes/ilias"
#git checkout $branch
#cd $CWD

# Run container the first time
cd "$FOLDERPATH"
../../manage/up.sh

#WIP
# get the docker process
#DCPROC=$(docker ps | grep $projectname)
#DCPROCHASH=${DCPROC:0:12}

# run the composer
#docker exec -t $DCPROCHASH /var/www/composer-install.sh
