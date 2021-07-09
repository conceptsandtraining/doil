#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/ilias-tool-doil
#
#                    .-.
#                   / /
#                  / |
#    |\     ._ ,-""  `.
#    | |,,_/  7        ;
#  `;=     ,=(     ,  /
#   |`q  q  ` |    \_,|
#  .=; <> _ ; /  ,/'/ |
# ';|\,j_ \;=\ ,/   `-'
#     `--'_|\  )
#    ,' | /  ;'
#   (,,/ (,,/      Thanks to Concepts and Training for supporting doil

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
    -n|--name)
      NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--repo)
      REPOSITORY="$2"
      shift # past argument
      shift # past value
      ;;
    -b|--branch)
      BRANCH="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--phpversion)
      PHPVERSION="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--target)
      TARGET="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help|help)
      eval "/usr/local/lib/doil/lib/instances/create/help.sh"
      exit
      ;;
    --skip-readme)
      SKIP_README=TRUE
      shift # past argument
      ;;
    -q|--quiet)
      QUIET=TRUE
      shift # past argument
      ;;
    *)    # unknown option
      echo -e "\033[1mERROR:\033[0m"
      echo -e "\tUnknown parameter!"
      echo -e "\tUse \033[1mdoil instances:create --help\033[0m for more information"
      exit 255
      ;;
	esac
done

# Pipe output to null if needed
if [[ ${QUIET} == TRUE ]]
then
  exec >>/var/log/doil.log 2>&1
fi

# check name
LINKPATH="${HOME}/.doil/${NAME}"
if [[ -z "${NAME}" ]]
then
  read -p "Name the instance for this ILIAS installation: " NAME
fi
if [[ -z "${NAME}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tName of the instance cannot be empty!"
  echo -e "\tsee \033[1mdoil instances:create --help\033[0m for more information"
  exit
elif [[ ${NAME} == *['!'@#\$%^\&\(\)*_+]* ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tInvalid characters! Only letters and numbers are allowed!"
  echo -e "\tsee \033[1mdoil instances:create --help\033[0m for more information"
  exit
elif [[ -h "${LINKPATH}" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\t${NAME} already exists!"
  echo -e "\tsee \033[1mdoil instances:create --help\033[0m for more information"
  exit
fi

# check repository
if [[ -z "${REPOSITORY}" ]]
then
  declare -a REPOSITORIES
  i=1
  while read LINE
  do
    REPONAME="$(cut -d'=' -f1 <<<${LINE})"

    REPOSITORIES[ $i ]=${REPONAME}
    (( i=($i+2) ))
  done < "${HOME}/.doil/config/repos"
  REPOSITORIES_STRING="${REPOSITORIES[*]}"

  read -p "Chose the repository [${REPOSITORIES_STRING//${IFS:0:1}/, }]: " REPOSITORY
fi
LINE=$(sed -n -e "/^${REPOSITORY}=/p" "${HOME}/.doil/config/repos")
if [ -z ${LINE} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tRepository ${REPOSITORY} does not exist!"
  echo -e "\tUse \033[1mdoil repo:list\033[0m to see all repositories!"
  exit 255
fi

# update the repository to get the branch
eval "doil repo:update ${REPOSITORY}"

# check branch
declare -a BRANCHES
cd "/usr/local/lib/doil/tpl/repos/${REPOSITORY}"
while read LINE
do
  if [[ ${LINE} == *['!'HEAD]* ]]
  then
    continue
  fi

  BRANCHES[ $i ]=${LINE#"remotes/origin/"}
  (( i=($i+2) ))
done < <(git branch -a | grep "remotes/origin")
BRANCHES_STRING="${BRANCHES[*]}"

if [[ -z "${BRANCH}" ]]
then
  read -p "Chose the branch [${BRANCHES_STRING//${IFS:0:1}/, }]: " BRANCH
fi

if [[ ! " ${BRANCHES[@]} " =~ " ${BRANCH} " ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tBranch ${BRANCH} does not exist!"
  echo -e "\tHere is a full list of the current branches:"
  git branch -a
  exit 255
fi
cd ${CWD}

# check php version
if [[ -z "${PHPVERSION}" ]]
then
  read -p "Chose the PHP Version [7.0, 7.1, 7.2, 7.3, 7.4, 8.0]: " PHPVERSION
fi
if [[ "${PHPVERSION}" != "7.0" ]] \
  && [[ "${PHPVERSION}" != "7.1" ]] \
  && [[ "${PHPVERSION}" != "7.2" ]] \
  && [[ "${PHPVERSION}" != "7.3" ]] \
  && [[ "${PHPVERSION}" != "7.4" ]] \
  && [[ "${PHPVERSION}" != "8.0" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tPHP Version ${PHPVERSION} is not supported!"
  echo -e "\tYou can use following versions: 7.0, 7.1, 7.2, 7.3, 7.4, 8.0"
  exit 255
fi

# determine the target
if [ -z ${TARGET} ]
then
  TARGET=${CWD}
fi
FOLDERPATH="${TARGET}/${NAME}"

doil_send_log "Start creating project ${NAME}"

# update debian
doil_send_log "Updating local system"
docker pull debian:stable --quiet

# check saltmain
doil system:salt start --quiet

# check proxy server
doil system:proxy start --quiet

##########################
# create the basic folders
doil_send_log "Create basic folders"

mkdir -p "${FOLDERPATH}/conf"
mkdir -p "${FOLDERPATH}/volumes/db"
mkdir -p "${FOLDERPATH}/volumes/index"
mkdir -p "${FOLDERPATH}/volumes/data"
mkdir -p "${FOLDERPATH}/volumes/logs/error"
mkdir -p "${FOLDERPATH}/volumes/logs/apache"

# set the link
ln -s "${FOLDERPATH}" "${HOME}/.doil/${NAME}"

#########################
# Copying necessary files
doil_send_log "Copying necessary files"

# docker stuff
cp "/usr/local/lib/doil/tpl/minion/run-supervisor.sh" "${FOLDERPATH}/conf/run-supervisor.sh"
cp "/usr/local/lib/doil/tpl/minion/Dockerfile" "${FOLDERPATH}/Dockerfile"
cp "/usr/local/lib/doil/tpl/stack/config/minion.cnf" "${FOLDERPATH}/conf/minion.cnf"
cp "/usr/local/lib/doil/tpl/minion/salt-minion.conf" "${FOLDERPATH}/conf/salt-minion.conf"
if [[ ${HOST} == 'linux' ]]
then
  cp "/usr/local/lib/doil/tpl/minion/docker-compose.yml" "${FOLDERPATH}/docker-compose.yml"
elif [[ ${HOST} == 'mac' ]]
then
  cp "/usr/local/lib/doil/tpl/minion/docker-compose-mac.yml" "${FOLDERPATH}/docker-compose.yml"
fi 

# setting up config file
touch "${FOLDERPATH}/conf/doil.conf"
echo "#!/bin/bash" > "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_NAME=\"${NAME}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_REPOSITORY=\"${REPOSITORY}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_BRANCH=\"${BRANCH}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_PHP_VERSION=\"${PHPVERSION}\"" >> "${FOLDERPATH}/conf/doil.conf"
chmod a+x "${FOLDERPATH}/conf/doil.conf"

# copy ilias
cd "/usr/local/lib/doil/tpl/repos/${REPOSITORY}"
git config core.fileMode false
git fetch origin --quiet
git checkout ${BRANCH} --quiet
git pull origin ${BRANCH} --quiet
cp -r "/usr/local/lib/doil/tpl/repos/${REPOSITORY}" "${FOLDERPATH}/volumes/ilias"
cd ${FOLDERPATH}

############################
# replace the templates vars
doil_send_log "Replacing template vars"

# replacer
if [ ${HOST} == "linux" ]; then
  sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "s/%DOILPATH%/\/usr\/lib\/doil/g" "${FOLDERPATH}/docker-compose.yml"

  sed -i "s/%USER_ID%/$(id -u ${USER})/g" "${FOLDERPATH}/Dockerfile"
  sed -i "s/%GROUP_ID%/$(id -g ${USER})/g" "${FOLDERPATH}/Dockerfile"
elif [ ${HOST} == "mac" ]; then
  sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "" "s/%DOILPATH%/\/usr\/local\/lib\/doil/g" "${FOLDERPATH}/docker-compose.yml"

  sed -i "" "s/%USER_ID%/$(id -u ${USER})/g" "${FOLDERPATH}/Dockerfile"
  sed -i "" "s/%GROUP_ID%/$(id -g ${USER})/g" "${FOLDERPATH}/Dockerfile"
fi

#######################
# building minion image
doil_send_log "Building minion image"

# build the image
cd ${FOLDERPATH}
docker-compose up --force-recreate --no-start --renew-anon-volumes --quiet-pull
doil up --quiet
sleep 5

##############
# checking key
doil_send_log "Checking key"

# check if the new key is registered
SALTKEYS=$(docker exec -t -i saltmain /bin/bash -c "salt-key -L" | grep "${NAME}.local")
until [[ ! -z ${SALTKEYS} ]]
do
  doil_send_log "Key not ready yet ... waiting"
  sleep 5
  SALTKEYS=$(docker exec -t -i saltmain /bin/bash -c "salt-key -L" | grep "${NAME}.local")
done
doil_send_log "Key ready"

############
# set grains
doil_send_log "Setting up local configuration"
GRAIN_MYSQL_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
docker exec -ti saltmain bash -c "salt '${NAME}.local' grains.set 'mysql_password' ${GRAIN_MYSQL_PASSWORD}"
docker exec -ti saltmain bash -c "salt '${NAME}.local' grains.set 'doil_domain' http://doil/${NAME}"
docker exec -ti saltmain bash -c "salt '${NAME}.local' grains.set 'doil_project_name' ${NAME}"
sleep 5

##################
# apply base state
doil_send_log "Apply base state"
doil apply ${NAME} base --quiet

#################
# apply dev state
doil_send_log "Apply dev state"
doil apply ${NAME} dev --quiet

#################
# apply php state
doil_send_log "Apply php state"
doil apply ${NAME} php${PHPVERSION} --quiet

###################
# apply ilias state
doil_send_log "Apply ilias state"
doil apply ${NAME} ilias --quiet

######################
# apply composer state
doil_send_log "Apply composer state"

ILIAS_VERSION_FILE=$(cat -e ${FOLDERPATH}/volumes/ilias/include/inc.ilias_version.php | grep "ILIAS_VERSION_NUMERIC")
ILIAS_VERSION=${ILIAS_VERSION_FILE:33:1}
if (( ${ILIAS_VERSION} == 6 ))
then
  doil apply ${NAME} composer --quiet
elif (( ${ILIAS_VERSION} > 6 ))
then
  doil apply ${NAME} composer2 --quiet
elif (( ${ILIAS_VERSION} < 6 ))
then
  doil apply ${NAME} composer54 --quiet
fi

###################
# try autoinstaller
if (( ${ILIAS_VERSION} > 6 ))
then
  doil_send_log "Trying autoinstaller"
  doil apply ${NAME} autoinstall --quiet
fi

#####
# apply access
doil_send_log "Apply access state"
doil apply ${NAME} access --quiet

#########################
# finalizing docker image
doil_send_log "Finalizing docker image"

# go to the minion and save the machine
cd ${FOLDERPATH}
DCFOLDER=${PWD##*/}
DCHASH=$(doil_get_hash ${DCFOLDER})
docker commit ${NAME} doil/${NAME}:stable

# stop the server
doil down ${NAME}

if [[ ${SKIP_README} != TRUE ]]
then
  ###########################
  # Copying readme to project
  doil_send_log "Copying readme to project"

  cp "/usr/local/lib/doil/tpl/minion/README.md" "${FOLDERPATH}/README.md"
  if [ ${HOST} == "linux" ]; then
    sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
    sed -i "s/%GRAIN_MYSQL_PASSWORD%/${GRAIN_MYSQL_PASSWORD}/g" "${FOLDERPATH}/README.md"
  elif [ ${HOST} == "mac" ]; then
    sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
    sed -i "" "s/%GRAIN_MYSQL_PASSWORD%/${GRAIN_MYSQL_PASSWORD}/g" "${FOLDERPATH}/README.md"
  fi
fi

#################
# Everything done
doil_send_log "Everything done"

echo -e "Your project is successfully installed. Head to your project via 'doil instances:cd ${NAME}' and see the readme file for more information about the usage with doil."