#!/bin/bash

# Get the settings
CWD=$(pwd)
WHOAMI=$(whoami)
TEMPLATES="/usr/lib/doil/tpl"

# Get all the needed information from the user
# set the project name
read -p "Name the instance for this container ILIAS installation: " projectname
if [ -z "$projectname" ]
then
  echo "You have to set a name for this instance! Aborting."
  exit 0
fi

# check if the instance if it exists
LINKPATH="/home/$WHOAMI/.doil/$projectname"
if [ -h "${LINKPATH}" ]
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
FOLDERPATH="$CWD/$projectname"
mkdir "$FOLDERPATH"
mkdir "$FOLDERPATH/conf"
mkdir "$FOLDERPATH/conf/lucene"
mkdir "$FOLDERPATH/volumes"
mkdir "$FOLDERPATH/volumes/db"
mkdir "$FOLDERPATH/volumes/index"
mkdir "$FOLDERPATH/volumes/data"
mkdir "$FOLDERPATH/volumes/logs"
mkdir "$FOLDERPATH/volumes/logs/error"

# set the link
ln -s "$FOLDERPATH" "/home/$WHOAMI/.doil/$projectname"

# copy the template filesDockerFile
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Copying necessary files"
cp "$TEMPLATES/docker-configs/debconf.selections" "$FOLDERPATH/conf/debconf.selections"
cp "$TEMPLATES/docker-configs/run-lamp.sh" "$FOLDERPATH/conf/run-lamp.sh"
cp "$TEMPLATES/docker-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
cp "$TEMPLATES/docker-configs/composer-install.sh" "$FOLDERPATH/conf/composer-install.sh"
cp "$TEMPLATES/misc/README.md" "$FOLDERPATH/README.md"

# copy lucene configs
cp "$TEMPLATES/lucene/init.sh" "$FOLDERPATH/conf/lucene/init.sh"
cp "$TEMPLATES/lucene/loop.sh" "$FOLDERPATH/conf/lucene/loop.sh"
cp "$TEMPLATES/lucene/ilServer.ini" "$FOLDERPATH/conf/lucene/ilServer.ini"

# copy the docker file
cp "$TEMPLATES/dockerfiles/Dockerfile$phpversion" "$FOLDERPATH/Dockerfile"
cp "$TEMPLATES/dockerfiles/Dockerfile.java" "$FOLDERPATH/Dockerfile.java"

# Copy the TMS scripts
if [ "$type" == "tms" ]
then
  mkdir "$FOLDERPATH/volumes/skins"
  mkdir "$FOLDERPATH/volumes/plugins"
  cp "$TEMPLATES/tms-configs/docker-compose.yml" "$FOLDERPATH/docker-compose.yml"
fi

# set the network for the server
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Setting up network."
SUB_NET_NAME="in-$projectname"
SUB_NET_NAME=${SUB_NET_NAME//-}

LINES=$(ls -l "/home/$WHOAMI/.doil/" | wc -l)
LINES=$(($LINES + 4))
SUB_NET_BASE="172.$LINES.0"

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

# replace the templates vars for port and phpversion
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Replacing temporary variables"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_TYPE%/$type/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PHPVERSION%/$phpversion/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_FOLDER%/$projectname/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_BASE%/$SUB_NET_BASE/g"
find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SUBNET_NAME%/$SUB_NET_NAME/g"
if [ "$type" == "tms" ]
then
  skinname=$skin
  if [ "$skin" == "all" ]
  then
    skinname="base54"
  fi
  find "$FOLDERPATH" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_SKIN%/$skinname/g"
fi

# clone ilias or tms
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Cloning ILIAS"
if [ "$type" == "ilias" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Updating ILIAS repository ..."
  doil update-repo ilias
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Finished updating ILIAS"
  cp -r "$TEMPLATES/repos/ilias/" "$FOLDERPATH/volumes/"
fi

if [ "$type" == "catilias" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Updating CAT ILIAS repository ..."
  doil update-repo catilias
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Finished updating CAT ILIAS"
  cp -r "$TEMPLATES/repos/catilias/" "$FOLDERPATH/volumes"
  mv "$FOLDERPATH/volumes/catilias" "$FOLDERPATH/volumes/ilias"
fi

if [ "$type" == "tms" ]
then
  echo "[$NOW] Updating TMS repository ..."
  doil update-repo tms
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Finished updating TMS"
  cp -r "$TEMPLATES/repos/tms/" "$FOLDERPATH/volumes/"
  mv "$FOLDERPATH/volumes/tms" "$FOLDERPATH/volumes/ilias"
fi

# Checkout the setted branch
cd "$FOLDERPATH/volumes/ilias"
git config core.fileMode false
git fetch origin
git checkout $branch
git pull origin $branch
cd $CWD

# Start the TMS Scripts
if [ "$type" == "tms" ]
then
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Cloning TMS skins"
  /usr/lib/doil/tms/skins.sh $projectname $skin
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] Cloning TMS plugins"
  /usr/lib/doil/tms/plugins.sh $projectname
fi

# initial startup
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Initial startup to install the mandatory dependencies"
cd "$FOLDERPATH"
doil up
/usr/lib/doil/install-composer.sh
doil down
cd "$CWD"
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Initial startup finished. Server shutted down."

# Goodbye txt
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[$NOW] Everything done."

read -p "If you want to see the README type YES: " readme
if [ "$readme" == "YES" ]
then
  cd "$FOLDERPATH"
  cat README.md
  cd "$CWD"
  echo " "
  echo "\\//. life long and prosper"
else
  echo "See README.md inside of your instance folder in $FOLDERPATH for more information about passwords and IPs"
  echo " "
  echo "\\//. life long and prosper"
fi
