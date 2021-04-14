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
    -v|--verbose)
      VERBOSE="YES"
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
  read -p "Chose the PHP Version [7.0, 7.1, 7.2, 7.3, 7.4]: " PHPVERSION
fi
if [[ "${PHPVERSION}" != "7.0" ]] \
  && [[ "${PHPVERSION}" != "7.1" ]] \
  && [[ "${PHPVERSION}" != "7.2" ]] \
  && [[ "${PHPVERSION}" != "7.3" ]] \
  && [[ "${PHPVERSION}" != "7.4" ]]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tPHP Version ${PHPVERSION} is not supported!"
  echo -e "\tYou can use following versions: 7.0, 7.1, 7.2, 7.3, 7.4"
  exit 255
fi

# determine the target
if [ -z ${TARGET} ]
then
  TARGET=${CWD}
fi
FOLDERPATH="${TARGET}/${NAME}"

##########################
# create the basic folders
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Start creating project ${NAME}"
echo "[${NOW}] Create basic folders"

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
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Copying necessary files"

# docker stuff
cp "/usr/local/lib/doil/tpl/minion/run-supervisor.sh" "${FOLDERPATH}/conf/run-supervisor.sh"
cp "/usr/local/lib/doil/tpl/minion/Dockerfile" "${FOLDERPATH}/Dockerfile"
cp "/usr/local/lib/doil/tpl/stack/config/minion.cnf" "${FOLDERPATH}/conf/minion.cnf"
cp "/usr/local/lib/doil/tpl/minion/salt-minion.conf" "${FOLDERPATH}/conf/salt-minion.conf"
cp "/usr/local/lib/doil/tpl/minion/run-salt-minion.sh" "${FOLDERPATH}/conf/run-salt-minion.sh"
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
git fetch origin
git checkout ${BRANCH}
git pull origin ${BRANCH}
cp -r "/usr/local/lib/doil/tpl/repos/${REPOSITORY}" "${FOLDERPATH}/volumes/ilias"
cd ${FOLDERPATH}

############################
# replace the templates vars
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Replacing template vars"

# replacer
if [ ${HOST} == "linux" ]; then
  sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "s/%DOILPATH%/\/usr\/lib\/doil/g" "${FOLDERPATH}/docker-compose.yml"
elif [ ${HOST} == "mac" ]; then
  sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "" "s/%DOILPATH%/\/usr\/local\/lib\/doil/g" "${FOLDERPATH}/docker-compose.yml"
fi

##############################
# starting master salt service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Starting master salt service"

# start service
cd /usr/local/lib/doil/tpl/main
docker-compose up -d
sleep 5

##############################
# checking master salt service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Checking master salt service"

# check if the salt-master service is running the service
DCMAIN=$(docker ps | grep "saltmain")
DCMAINHASH=${DCMAIN:0:12}

DCMAINSALTSERVICE=$(docker top ${DCMAINHASH} | grep "salt-master")
if [[ -z ${DCMAINSALTSERVICE} ]]
then
  $(docker exec -ti ${DCMAINHASH} bash -c "salt-master -d")
fi

until [[ ! -z ${DCMAINSALTSERVICE} ]]
do
  echo "Master service not ready ..."
  doil salt:restart
  DCMAINSALTSERVICE=$(docker top ${DCMAINHASH} | grep "salt-master")
done
echo "Master service ready."

# set the saltmain again because we maybe did restart the service
DCMAIN=$(docker ps | grep "saltmain")
DCMAINHASH=${DCMAIN:0:12}

#######################
# building minion image
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Building minion image"

# build the image
cd ${FOLDERPATH}
docker-compose up --force-recreate --no-start --renew-anon-volumes

##############################
# starting salt minion service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Starting salt minion service"

# start the docker service
cd ${FOLDERPATH}
docker-compose up -d
sleep 5

#########################
# checking minion service
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Checking minion service"

# check if the service is running
cd ${FOLDERPATH}
DCMINIONFOLDER=${PWD##*/}
DCMINIONHASH=$(doil_get_hash ${DCMINIONFOLDER})
DCMINIONSALTSERVICE=$(docker container top ${DCMINIONHASH} | grep "salt-minion")

# wait until the service is there
if [[ -z ${DCMINIONSALTSERVICE} ]]
then
  echo "Minion service not ready ... starting"
  docker exec -ti ${DCMINIONHASH} bash -c "salt-minion -d"
  sleep 5
fi

# check if the new key is registered
SALTKEYS=$(docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt-key -L" | grep "${NAME}.local")
until [[ ! -z ${SALTKEYS} ]]
do
  echo "Key not ready yet ... waiting"
  sleep 5
  SALTKEYS=$(docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt-key -L" | grep "${NAME}.local")
done
echo "Key ready"

##################
# apply base state
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply base state"
docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=base --state-output=terse"

#################
# apply dev state
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply dev state"
docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=dev --state-output=terse"

#################
# apply php state
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply php state"
docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=php${PHPVERSION} --state-output=terse"

###################
# apply ilias state
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply ilias state"
docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=ilias --state-output=terse"

######################
# apply composer state
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Apply composer state"

ILIAS_VERSION_FILE=$(cat -e ${FOLDERPATH}/volumes/ilias/include/inc.ilias_version.php | grep "ILIAS_VERSION_NUMERIC")
ILIAS_VERSION=${ILIAS_VERSION_FILE:33:1}
if (( ${ILIAS_VERSION} == 6 ))
then
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=composer --state-output=terse"
elif (( ${ILIAS_VERSION} > 6 ))
then
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=composer2 --state-output=terse"
elif (( ${ILIAS_VERSION} < 6 ))
then
  docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${NAME}.local' state.highstate saltenv=composer54 --state-output=terse"
fi

#########################
# finalizing docker image
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Finalizing docker image"

# go to the minion and save the machine
cd ${FOLDERPATH}
DCFOLDER=${PWD##*/}
DCHASH=$(doil_get_hash ${DCFOLDER})
docker commit ${DCHASH} doil/${NAME}:stable

# stop the server
doil down

###########################
# Copying readme to project
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Copying readme to project"

cp "/usr/local/lib/doil/tpl/minion/README.md" "${FOLDERPATH}/README.md"
if [ ${HOST} == "linux" ]; then
  sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
elif [ ${HOST} == "mac" ]; then
  sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
fi

#################
# Everything done
NOW=$(date +'%d.%m.%Y %I:%M:%S')
echo "[${NOW}] Everything done"

echo -e "Your project is successfully installed. Head to your project via 'doil instances:cd ${NAME}' and see the readme file for more information about the usage with doil."