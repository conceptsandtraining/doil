#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

# get the helper
source /usr/local/lib/doil/lib/include/env.sh
source /usr/local/lib/doil/lib/include/log.sh
source /usr/local/lib/doil/lib/include/helper.sh

# set current ad
CWD=$(pwd)

# check if command is just plain help
# if we don't have any command we load the help
while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
    -n|--name)
      NAME="${2}"
      shift # past argument
      shift # past value
      ;;
    -r|--repo)
      LOCAL_REPOSITORY=TRUE
      REPOSITORY="${2}"
      shift # past argument
      shift # past value
      ;;
    -gr|--global-repo)
      GLOBAL_REPOSITORY=TRUE
      REPOSITORY="${2}"
      shift # past argument
      shift # past value
      ;;
    -b|--branch)
      BRANCH="${2}"
      shift # past argument
      shift # past value
      ;;
    -p|--phpversion)
      PHPVERSION="${2}"
      shift # past argument
      shift # past value
      ;;
    -t|--target)
      TARGET="${2}"
      shift # past argument
      shift # past value
      ;;
    -g|--global)
      GLOBAL=TRUE
      shift # past argument
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
  done < "${HOME}/.doil/config/repositories.conf"

  while read LINE
  do
    REPONAME="$(cut -d'=' -f1 <<<${LINE})"

    REPOSITORIES[ $i ]="${REPONAME}_global"
    (( i=($i+2) ))
  done < "/etc/doil/repositories.conf"
  REPOSITORIES_STRING="${REPOSITORIES[*]}"
  read -p "Chose the repository [${REPOSITORIES_STRING//${IFS:0:1}/, }]: " REPOSITORY
fi

if [[ ! -z ${GLOBAL_REPOSITORY} ]] # check if we got the repository from -gr
then
  LINE=$(sed -n -e "/^${REPOSITORY}=/p" "/etc/doil/repositories.conf")
  SKIP_WIZZARD=TRUE
elif [[ ! -z ${LOCAL_REPOSITORY} ]] # check if we got a local repository from -r
then
  LINE=$(sed -n -e "/^${REPOSITORY}=/p" "${HOME}/.doil/config/repositories.conf")
  SKIP_WIZZARD=TRUE
else # we got the repository from the wizzard
  if [[ ${REPOSITORY} == *"_global"* ]] # check for _global suffix
  then
    REPOSITORY=${REPOSITORY%"_global"}
    LINE=$(sed -n -e "/^${REPOSITORY}=/p" "/etc/doil/repositories.conf")
    GLOBAL_REPOSITORY=TRUE
  else
    LINE=$(sed -n -e "/^${REPOSITORY}=/p" "${HOME}/.doil/config/repositories.conf")
    LOCAL_REPOSITORY=TRUE
  fi
fi

if [ -z ${LINE} ]
then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tRepository ${REPOSITORY} does not exist!"
  echo -e "\tUse \033[1mdoil repo:list\033[0m to see all repositories!"
  exit 255
fi

# update the repository to get the branch
doil_status_send_message "Updating repository ${REPOSITORY}"
if [[ ${GLOBAL_REPOSITORY} == TRUE ]]
then
  eval "doil repo:update ${REPOSITORY}" --global --quiet
else
  eval "doil repo:update ${REPOSITORY}" --quiet
fi
doil_status_okay

# check branch
declare -a BRANCHES
if [[ ${GLOBAL_REPOSITORY} == "TRUE" ]]
then
  cd "/usr/local/share/doil/repositories/${REPOSITORY}"
else
  cd "${HOME}/.doil/repositories/${REPOSITORY}"
fi

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

# config
DOIL_HOST=$(doil_get_conf host)

# update debian
doil_status_send_message "Updating debian image"
docker pull debian:stable --quiet > /dev/null
doil_status_okay

# salt and proxy server
doil_status_send_message "Starting mandatory doil services"
doil system:salt start --quiet
doil system:proxy start --quiet
doil_status_okay

# create the basic folders
doil_status_send_message "Create basic folders"

mkdir -p "${FOLDERPATH}/conf"
mkdir -p "${FOLDERPATH}/conf/salt"
mkdir -p "${FOLDERPATH}/volumes/db"
mkdir -p "${FOLDERPATH}/volumes/index"
mkdir -p "${FOLDERPATH}/volumes/data"
mkdir -p "${FOLDERPATH}/volumes/logs/error"
mkdir -p "${FOLDERPATH}/volumes/logs/apache"
mkdir -p "${FOLDERPATH}/volumes/etc/apache2"
mkdir -p "${FOLDERPATH}/volumes/etc/php"
mkdir -p "${FOLDERPATH}/volumes/etc/mysql"

# set the link
if [[ ${GLOBAL} == "TRUE" ]]
then
  ln -s "${FOLDERPATH}" "/usr/local/share/doil/instances/${NAME}"
else
  ln -s "${FOLDERPATH}" "${HOME}/.doil/instances/${NAME}"
fi
doil_status_okay

# set user permissions
doil_status_send_message "Setting folder permissions"
if [[ -z ${GLOBAL} ]]
then
  chown -R ${USER}:${USER} ${FOLDERPATH}
else
  chown -R ${USER}:doil ${FOLDERPATH}
  chmod g+w ${FOLDERPATH}
  chmod g+s ${FOLDERPATH}
  chown ${USER}:doil "/usr/local/share/doil/instances/${NAME}"
fi
doil_status_okay

# Copying necessary files
doil_status_send_message "Copying necessary files"
cp "/usr/local/share/doil/templates/minion/run-supervisor.sh" "${FOLDERPATH}/conf/run-supervisor.sh"
cp "/usr/local/share/doil/templates/minion/Dockerfile" "${FOLDERPATH}/Dockerfile"
cp "/usr/local/share/doil/templates/minion/salt-minion.conf" "${FOLDERPATH}/conf/salt-minion.conf"
cp "/usr/local/share/doil/templates/minion/docker-compose.yml" "${FOLDERPATH}/docker-compose.yml"
cp "/usr/local/share/doil/stack/config/minion.cnf" "${FOLDERPATH}/conf/minion.cnf"
doil_status_okay

# setting up config file
doil_status_send_message "Setting up configuration"
touch "${FOLDERPATH}/conf/doil.conf"
echo "#!/bin/bash" > "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_NAME=\"${NAME}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_REPOSITORY=\"${REPOSITORY}\"" >> "${FOLDERPATH}/conf/doil.conf"
PROJECT_REPOSITORY_URL=$(doil repo:list | grep ${REPOSITORY} -w | cut -d\   -f3)
echo "PROJECT_REPOSITORY_URL=\"${PROJECT_REPOSITORY_URL}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_BRANCH=\"${BRANCH}\"" >> "${FOLDERPATH}/conf/doil.conf"
echo "PROJECT_PHP_VERSION=\"${PHPVERSION}\"" >> "${FOLDERPATH}/conf/doil.conf"
chmod a+x "${FOLDERPATH}/conf/doil.conf"
doil_status_okay

# copy ilias
doil_status_send_message "Copying repository to target"
if [[ ${GLOBAL_REPOSITORY} == "TRUE" ]]
then
  cd "/usr/local/share/doil/repositories/${REPOSITORY}"
else
  cd "${HOME}/.doil/repositories/${REPOSITORY}"
fi

# updating the git repo
git config core.fileMode false
git checkout origin/${BRANCH} --quiet > /dev/null
git branch -D ${BRANCH} --quiet > /dev/null
git checkout -b ${BRANCH} --quiet > /dev/null

if [[ ${GLOBAL_REPOSITORY} == "TRUE" ]]
then
  cp -r "/usr/local/share/doil/repositories/${REPOSITORY}" "${FOLDERPATH}/volumes/ilias"
else
  cp -r "${HOME}/.doil/repositories/${REPOSITORY}" "${FOLDERPATH}/volumes/ilias"
fi
cd ${FOLDERPATH}
doil_status_okay

############################
# replace the templates vars
doil_status_send_message "Replacing template vars"

if [[ ${GLOBAL} == TRUE ]]
then
  SUFFIX="global"
  FLAG="--global"
else
  SUFFIX="local"
  FLAG=""
fi

# replacer
if [ ${HOST} == "linux" ]; then
  sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "s/%TPL_PROJECT_DOMAINNAME%/${SUFFIX}/g" "${FOLDERPATH}/docker-compose.yml"

  sed -i "s/%USER_ID%/$(id -u ${USER})/g" "${FOLDERPATH}/Dockerfile"
  sed -i "s/%GROUP_ID%/$(id -g ${USER})/g" "${FOLDERPATH}/Dockerfile"
elif [ ${HOST} == "mac" ]; then
  sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/docker-compose.yml"
  sed -i "" "s/%TPL_PROJECT_DOMAINNAME%/${SUFFIX}/g" "${FOLDERPATH}/docker-compose.yml"

  sed -i "" "s/%USER_ID%/$(id -u ${USER})/g" "${FOLDERPATH}/Dockerfile"
  sed -i "" "s/%GROUP_ID%/$(id -g ${USER})/g" "${FOLDERPATH}/Dockerfile"
fi
doil_status_okay

#######################
# building minion image
doil_status_send_message "Building minion image"

# build the image
cd ${FOLDERPATH}
TMP_BUILD=$(docker build -t doil/${NAME}_${SUFFIX} . 2>&1 > /dev/null)
TMP_RUN=$(docker run -d --name ${NAME}_${SUFFIX} doil/${NAME}_${SUFFIX} 2>&1 > /dev/null)

# mariadb
docker exec -i ${NAME}_${SUFFIX} bash -c "apt install -y mariadb-server python3-mysqldb 2>&1 > /dev/null" 2>&1 > /dev/null
docker exec -i ${NAME}_${SUFFIX} bash -c "/etc/init.d/mariadb start" > /dev/null
sleep 5
docker exec -i ${NAME}_${SUFFIX} bash -c "/etc/init.d/mariadb stop" 2>&1 > /dev/null

# copy the config
docker cp ${NAME}_${SUFFIX}:/etc/apache2 ./volumes/etc/
docker cp ${NAME}_${SUFFIX}:/etc/php ./volumes/etc/
docker cp ${NAME}_${SUFFIX}:/var/log/apache2/ ./volumes/logs/
docker cp ${NAME}_${SUFFIX}:/etc/mysql/ ./volumes/etc/
docker cp ${NAME}_${SUFFIX}:/var/lib/mysql/ ./volumes/

# stop image
docker commit ${NAME}_${SUFFIX} doil/${NAME}_${SUFFIX}:stable 2>&1 > /dev/null
TMP_STOP=$(docker stop ${NAME}_${SUFFIX}) 2>&1 > /dev/null
TMP_RM=$(docker rm ${NAME}_${SUFFIX}) 2>&1 > /dev/null

# start container via docker-compose
DDUP=$(doil up ${NAME} --quiet ${FLAG} 2>&1 > /dev/null)
docker exec -i ${NAME}_${SUFFIX} bash -c "chown -R mysql:mysql /var/lib/mysql" > /dev/null
docker exec -i ${NAME}_${SUFFIX} bash -c "/etc/init.d/mariadb start" > /dev/null
sleep 5

doil_status_okay

##############
# checking key
doil_status_send_message "Checking key"

# check if the new key is registered
SALTKEYS=$(docker exec -t -i saltmain /bin/bash -c "salt-key -L" | grep "${NAME}.${SUFFIX}")
until [[ ! -z ${SALTKEYS} ]]
do
  docker exec -i ${NAME}_${SUFFIX} bash -c "killall -9 salt-minion" > /dev/null
  docker exec -i ${NAME}_${SUFFIX} bash -c "rm -rf /var/lib/salt/pki/minion/*" > /dev/null
  docker exec -i ${NAME}_${SUFFIX} bash -c "salt-minion -d" > /dev/null
  sleep 5
  SALTKEYS=$(docker exec -t -i saltmain /bin/bash -c "salt-key -L" | grep "${NAME}.${SUFFIX}")  
done
doil_status_okay

############
# set grains
doil_status_send_message "Setting up instance configuration"
GRAIN_MYSQL_PASSWORD=$(xxd -l8 -ps /dev/urandom | head -c 13 ; echo '')
GRAIN_CRON_PASSWORD=$(xxd -l8 -ps /dev/urandom | head -c 13 ; echo '')
docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'mysql_password' ${GRAIN_MYSQL_PASSWORD} --out=quiet"
docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'cron_password' ${GRAIN_CRON_PASSWORD} --out=quiet"
docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'doil_domain' http://${DOIL_HOST}/${NAME} --out=quiet"
docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'doil_project_name' ${NAME} --out=quiet"
if [[ "$(< /proc/version)" == *@(Microsoft|WSL)* ]]
then
  docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'doil_host_system' windows --out=quiet"
else
  docker exec -i saltmain bash -c "salt '${NAME}.${SUFFIX}' grains.set 'doil_host_system' linux --out=quiet"  
fi

sleep 5
doil_status_okay

##################
# apply base state
set -e
doil_status_send_message "Apply base state"
OUTPUT=$(doil apply ${NAME} base ${FLAG} -c)
if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

#################
# apply dev state
doil_status_send_message "Apply dev state"
OUTPUT=$(doil apply ${NAME} dev -c ${FLAG})
if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

#################
# apply php state
doil_status_send_message "Apply php state"
OUTPUT=$(doil apply ${NAME} php${PHPVERSION} -c ${FLAG})
if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

###################
# apply ilias state
doil_status_send_message "Apply ilias state"
OUTPUT=$(doil apply ${NAME} ilias -c ${FLAG})
if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

######################
# apply composer state
doil_status_send_message "Apply composer state"

ILIAS_VERSION_FILE=$(cat -e ${FOLDERPATH}/volumes/ilias/include/inc.ilias_version.php | grep "ILIAS_VERSION_NUMERIC")
ILIAS_VERSION=${ILIAS_VERSION_FILE:33:1}
if (( ${ILIAS_VERSION} == 6 ))
then
  OUTPUT=$(doil apply ${NAME} composer -c ${FLAG})
  if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
  then
    doil_status_failed
    exit
  fi
elif (( ${ILIAS_VERSION} > 6 ))
then
  OUTPUT=$(doil apply ${NAME} composer2 -c ${FLAG})
  if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
  then
    doil_status_failed
    exit
  fi
elif (( ${ILIAS_VERSION} < 6 ))
then
  OUTPUT=$(doil apply ${NAME} composer54 -c ${FLAG})
  if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
  then
    doil_status_failed
    exit
  fi
fi
doil_status_okay

###################
# try autoinstaller
if (( ${ILIAS_VERSION} > 6 ))
then
  doil_status_send_message "Trying autoinstaller"
  OUTPUT=$(doil apply ${NAME} autoinstall -c ${FLAG})
  if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
  then
    doil_status_failed
  else
    doil_status_okay
  fi
fi

#####
# apply access
doil_status_send_message "Apply access state"
OUTPUT=$(doil apply ${NAME} access -c ${FLAG})
if [[ ${OUTPUT} == *"Minions returned with non-zero exit code"* ]]
then
  doil_status_failed
  exit
fi
doil_status_okay

#########################
# finalizing docker image
doil_status_send_message "Finalizing docker image"
cd ${FOLDERPATH}
docker commit ${NAME}_${SUFFIX} doil/${NAME}_${SUFFIX}:stable > /dev/null
doil_status_okay

# stop the server
DDOWN=$(doil down ${NAME} ${FLAG} --quiet 2>&1 > /dev/null)  2>&1 > /dev/null

if [[ ${SKIP_README} != TRUE ]]
then
  ###########################
  # Copying readme to project
  doil_status_send_message "Copying readme to project"

  cp "/usr/local/share/doil/templates/minion/README.md" "${FOLDERPATH}/README.md"
  if [ ${HOST} == "linux" ]; then
    sed -i "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
    sed -i "s/%GRAIN_MYSQL_PASSWORD%/${GRAIN_MYSQL_PASSWORD}/g" "${FOLDERPATH}/README.md"
    sed -i "s/%GRAIN_CRON_PASSWORD%/${GRAIN_CRON_PASSWORD}/g" "${FOLDERPATH}/README.md"
  elif [ ${HOST} == "mac" ]; then
    sed -i "" "s/%TPL_PROJECT_NAME%/${NAME}/g" "${FOLDERPATH}/README.md"
    sed -i "" "s/%GRAIN_MYSQL_PASSWORD%/${GRAIN_MYSQL_PASSWORD}/g" "${FOLDERPATH}/README.md"
    sed -i "" "s/%GRAIN_CRON_PASSWORD%/${GRAIN_CRON_PASSWORD}/g" "${FOLDERPATH}/README.md"
  fi

  doil_status_okay
fi

#################
# Everything done
doil_send_log "Everything done"

echo -e "Your project is successfully created. Head to your project via 'doil instances:cd ${NAME}' and see the readme file for more information about the usage with doil."