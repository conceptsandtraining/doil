#!/bin/bash

# Set the config. You might adjust the urls
ILIAS_URL_SSH="git@github.com:ILIAS-eLearning/ILIAS.git"
ILIAS_URL_HTTPS="https://github.com/ILIAS-eLearning/ILIAS.git"
TMS_URL_SSH="git@github.com:conceptsandtraining/TMS.git"
TMS_URL_HTTPS="https://github.com/conceptsandtraining/TMS.git"

# set current folder
CWD=$(pwd)
TEMPLATES="$CWD/templates"

# get all the infos
read -p "Name the folder for the ILIAS installation [usually dc-panasonic or dc-devk]: " folder
read -p "Set the PHP version for this installation: " phpversion
read -p "Set the port for this installation: " port
read -p "Set the type of your installation [options are: ilias or tms]: " type
read -p "Select the branch of the installation [e.g. release_5-4]: " branch
#read -p "Do you want to do an automatic installation? [Type YES or NO in uppercase]: " autoinstall
read -p "Get ILIAS over SSH (github account required) or HTTPS? [Type SSH or HTTPS in uppercase]: " protocol

# we got all the information now we start to build the structure
# first we create the needed folders
mkdir "$CWD/../$folder"
mkdir "$CWD/../$folder/conf"
mkdir "$CWD/../$folder/src"
mkdir "$CWD/../$folder/src/ilias"
mkdir "$CWD/../$folder/src/data"
mkdir "$CWD/../$folder/src/logs"
mkdir "$CWD/../$folder/src/logs/error"

# copy the template filesDockerFile
cp "$TEMPLATES/docker-configs/debconf.selections" "$CWD/../$folder/conf/debconf.selections"
cp "$TEMPLATES/docker-configs/run-lamp.sh" "$CWD/../$folder/conf/run-lamp.sh"
cp "$TEMPLATES/docker-configs/docker-compose.yml" "$CWD/../$folder/docker-compose.yml"
cp "$TEMPLATES/docker-configs/Dockerfile" "$CWD/../$folder/Dockerfile"
cp "$TEMPLATES/ilias-configs/composer-install.sh" "$CWD/../$folder/conf/composer-install.sh"
cp "$TEMPLATES/up.sh" "$CWD/../$folder/up.sh"
cp "$TEMPLATES/down.sh" "$CWD/../$folder/down.sh"
cp "$TEMPLATES/login.sh" "$CWD/../$folder/login.sh"

# Copy the TMS scripts
if [ "$type" == "tms" ]
then
  mkdir "$CWD/../$folder/src/skins"
  cp "$TEMPLATES/tms-configs/tms-download-skins.sh" "$CWD/../$folder/conf/tms-download-skins.sh"
  cp "$TEMPLATES/tms-configs/tms-download-plugins.sh" "$CWD/../$folder/conf/tms-download-plugins.sh"
  cp "$TEMPLATES/tms-configs/docker-compose.yml" "$CWD/../$folder/docker-compose.yml"
fi

# replace the templates vars for port and phpversion
find "$CWD/../$folder" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PHPVERSION%/$phpversion/g"
find "$CWD/../$folder" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PORT%/$port/g"
find "$CWD/../$folder" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_FOLDER%/$folder/g"

# clone ilias or tms
if [ "$type" == "ilias" ]
then
  if [ "$protocol" == "SSH" ]
  then
  	git clone $ILIAS_URL_SSH "$CWD/../$folder/src/ilias"
  elif [ "$protocol" == "HTTPS" ]
  then
    git clone $ILIAS_URL_HTTPS "$CWD/../$folder/src/ilias"
  fi
fi

if [ "$type" == "tms" ]
then
  git clone $TMS_URL_SSH "$CWD/../$folder/src/ilias"
fi

# Start the TMS Scripts
if [ "$type" == "tms" ]
then
  cd "$CWD/../$folder/conf"
  ./tms-download-skins.sh
  ./tms-download-plugins.sh
fi

# Checkout the setted branch
cd "$CWD/../$folder/src/ilias"
git checkout $branch
cd $CWD


# Run container the first time
cd "$CWD/../$folder"
./up.sh

#WIP
# get the docker process
#DCPROC=$(docker ps | grep $folder)
#DCPROCHASH=${DCPROC:0:12}

# run the composer
#docker exec -t $DCPROCHASH /var/www/composer-install.sh
