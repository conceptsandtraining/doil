#!/bin/bash

source /usr/lib/doil/helper.sh

# Get the settings
CWD=$(pwd)
WHOAMI=$(whoami)

# Check if the current directory is writeable
if [ ! -w `pwd` ]; then
  echo -e "\033[1mERROR:\033[0m"
  echo -e "\tThe current directory is not writeable for you."
  echo -e "\tPlease head to a different directory."

  exit
fi

# setup basic dialog stuff
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_error() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0 
}

# ask for the project name
is_projectname=FALSE
while [ ${is_projectname} == FALSE ]; do
  exec 3>&1
  projectname=$(dialog \
    --backtitle "doil - create" \
    --title "doil - create - (1/4)" \
    --clear \
    --cancel-label "Exit" \
    --inputbox "Set up a name for your project" ${HEIGHT} ${WIDTH} "" \
      3>&1 1>&2 2>&3)
  exit_status=$?
  exec 3>&-
  case ${exit_status} in
    ${DIALOG_CANCEL})
      clear
      echo "Program terminated."
      exit
    ;;
    ${DIALOG_ESC})
      clear
      echo "Program aborted." >&2
      exit 1
    ;;
  esac

  LINKPATH="/home/${WHOAMI}/.doil/${projectname}"
  if [[ -z "${projectname}" ]]
  then
    result="The name of the project cannot be empty!"
    display_error "Error!"
  elif [[ ${projectname} == *['!'@#\$%^\&*()_+]* ]]
  then
    result="You are using an invalid character! Only letters and numbers are allowed!"
    display_error "Error!"
  elif [[ -h "${LINKPATH}" ]]
  then
    result="${projectname} already exists!"
    display_error "Error!"
  else
    is_projectname=TRUE
    clear
  fi
done

# get the project type
# this also will setup the available branches and the type of the saltstack to use
is_projecttype=FALSE
declare -a projecttypes
i=1
while read line
do
  projecttypename="$(cut -d'=' -f1 <<<${line})"
  projecttyperepo="$(cut -d'=' -f2 <<<${line})"

  projecttypes[ $i ]=${projecttypename}
  projecttypes[ ( $i + 1 ) ]=${projecttyperepo}
  (( i=($i+2) ))
done < "/home/${WHOAMI}/.doil/config/repos"

while [ ${is_projecttype} == FALSE ]; do
  exec 3>&1
  projecttype=$(dialog \
    --backtitle "doil - create" \
    --title "doil - create - (2/4)" \
    --clear \
    --cancel-label "Exit" \
    --menu "Set the type for your project" ${HEIGHT} ${WIDTH} "" \
      "${projecttypes[@]}" \
      3>&1 1>&2 2>&3)
  exit_status=$?
  exec 3>&-
  case ${exit_status} in
    ${DIALOG_CANCEL})
      clear
      echo "Program terminated."
      exit
    ;;
    ${DIALOG_ESC})
      clear
      echo "Program aborted." >&2
      exit 1
    ;;
  esac
  is_projecttype=TRUE
  clear
done

# get the branch
echo "Fetching data ... stand by."
is_projectbranch=FALSE
declare -a projectbranches
i=1
cd "/usr/lib/doil/tpl/repo/${projecttype}"
git fetch origin -q

while read line
do
  if [[ ${line} == *['!'HEAD]* ]]
  then
    continue
  fi

  projectbranches[ $i ]=${line#"remotes/origin/"}
  projectbranches[ $i + 1 ]=${line}
  (( i=($i+2) ))
done < <(git branch -a | grep "remotes/origin")

while [ ${is_projectbranch} == FALSE ]; do
  exec 3>&1
  projectbranch=$(dialog \
    --backtitle "doil - create" \
    --title "doil - create - (3/4)" \
    --clear \
    --cancel-label "Exit" \
    --menu "Set the branch for your project" ${HEIGHT} ${WIDTH} "" \
      "${projectbranches[@]}" \
      3>&1 1>&2 2>&3)
  exit_status=$?
  exec 3>&-
  case ${exit_status} in
    ${DIALOG_CANCEL})
      clear
      echo "Program terminated."
      exit
    ;;
    ${DIALOG_ESC})
      clear
      echo "Program aborted." >&2
      exit 1
    ;;
  esac
  is_projectbranch=TRUE
  clear
done

# ask for autoinstaller
dialog \
  --backtitle "doil - create" \
  --title "doil - create - (4/4)" \
  --clear \
  --yesno "Sometimes it is possible to install ILIAS automatically. Do you want to try it?" ${HEIGHT} ${WIDTH}
projectautoinstall=$?
clear
if [[ ${projectautoinstall} == 0 ]]
then
  projectautoinstall="yes"
else
  projectautoinstall="no"
fi

# start the process
DIALOG=dialog
(
  ##########################
  # create the basic folders
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Create basic folders"
  
    FOLDERPATH="$CWD/${projectname}"
    mkdir -p "${FOLDERPATH}/conf"
    mkdir -p "${FOLDERPATH}/volumes/db"
    mkdir -p "${FOLDERPATH}/volumes/index"
    mkdir -p "${FOLDERPATH}/volumes/data"
    mkdir -p "${FOLDERPATH}/volumes/logs/error"
    mkdir -p "${FOLDERPATH}/volumes/logs/apache"

    # set the link
    ln -s "${FOLDERPATH}" "/home/${WHOAMI}/.doil/${projectname}"
  )

  #########################
  # Copying necessary files
  echo "XXX"; echo "Copying necessary files"; echo "XXX"
  echo "5"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Copying necessary files"

    # docker stuff
    cp "/usr/lib/doil/tpl/minion/run-supervisor.sh" "${FOLDERPATH}/conf/run-supervisor.sh"
    cp "/usr/lib/doil/tpl/minion/docker-compose.yml" "${FOLDERPATH}/docker-compose.yml"
    cp "/usr/lib/doil/tpl/minion/Dockerfile" "${FOLDERPATH}/Dockerfile"

    # copy ilias
    cd "/usr/lib/doil/tpl/repo/${projecttype}"
    git fetch origin
    git checkout ${projectbranch}
    git pull origin ${$projectbranch}
    cp -r "/usr/lib/doil/tpl/repo/${projecttype}" "${FOLDERPATH}/volumes/ilias"
  )

  ############################
  # replace the templates vars
  echo "XXX"; echo "Replacing templates vars"; echo "XXX"
  echo "9"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Replacing template vars"

    # replacer
    find "${FOLDERPATH}" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PROJECT_NAME%/${projectname}/g"
  )

  ##############################
  # starting master salt service
  echo "XXX"; echo "Starting master salt service"; echo "XXX"
  echo "10"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Starting master salt service"

    # start service
    cd /usr/lib/doil/tpl/main
    docker-compose up -d
  )

  ##############################
  # checking master salt service
  echo "XXX"; echo "Checking master salt service"; echo "XXX"
  echo "17"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Checking master salt service"

    # check if the salt-master service is running the service
    DCMAINPROC=$(docker ps | grep "saltmain")
    DCMAINPROCHASH=${DCMAINPROC:0:12}

    DCMAINSALTSERVICE=$(docker exec -ti ${DCMAINPROCHASH} bash -c "ps -aux | grep salt-master" | grep "/usr/bin/salt-master -d")
    if [[ -z ${DCMAINSALTSERVICE} ]]
    then
      $(docker exec -ti ${DCMAINPROCHASH} bash -c "salt-master -d")
    fi
  )

  #######################
  # building minion image
  echo "XXX"; echo "Building minion image"; echo "XXX"
  echo "20"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Building minion image"

    # build the image
    cd ${FOLDERPATH}
    docker-compose build
  )

  ##############################
  # starting salt minion service
  echo "XXX"; echo "Starting salt minion service"; echo "XXX"
  echo "30"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Starting salt minion service"

    # start the docker service
    cd ${FOLDERPATH}
    docker-compose up -d
  )

  ##############################
  # checking minion service
  echo "XXX"; echo "Checking minion service"; echo "XXX"
  echo "35"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Checking minion service"

    # check if the service is running
    DCMINIONFOLDER=${PWD##*/}
    DCMINIONHASH=$(doil_get_hash ${DCMINIONFOLDER})

    DCMINIONSALTSERVICE=$(docker exec -ti ${DCMINIONPROCHASH} bash -c "ps -aux | grep salt-minion" | grep "/usr/bin/salt-minion -d")
    if [[ -z ${DCMINIONSALTSERVICE} ]]
    then
      $(docker exec -ti ${DCMINIONPROCHASH} bash -c "salt-minion -d")
    fi

    # check if the new key is registered
    DCMAINPROC=$(docker ps | grep "saltmain")
    DCMAINPROCHASH=${DCMAINPROC:0:12}
    SALTKEYS=$(docker exec -t -i ${DCMAINPROCHASH} /bin/bash -c "salt-key -L" | grep "${projectname}.local")
    if [ -z ${SALTKEYS} ]
    then
      echo "Something went wrong registering the minion to the main server. So we do it again ..."
      docker exec -t -i ${DCMINIONHASH} /bin/bash -c "killall -9 salt-minion"
      docker exec -t -i ${DCMINIONHASH} /bin/bash -c "salt-minion -d"
    fi
  )

  ##################
  # apply base state
  echo "XXX"; echo "Apply base state"; echo "XXX"
  echo "40"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Apply base state"

    # apply base state
    DCMAINPROC=$(docker ps | grep "saltmain")
    DCMAINPROCHASH=${DCMAINPROC:0:12}
    docker exec -t -i ${DCMAINPROCHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=base --state-output=terse"
  )

  #################
  # apply dev state
  echo "XXX"; echo "Apply dev state"; echo "XXX"
  echo "60"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Apply dev state"

    # apply base state
    DCMAINPROC=$(docker ps | grep "saltmain")
    DCMAINPROCHASH=${DCMAINPROC:0:12}
    docker exec -t -i ${DCMAINPROCHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=dev --state-output=terse"
  )

  ###################
  # apply ilias state



  #########################
  # finalizing docker image
  echo "XXX"; echo "Finalizing docker image"; echo "XXX"
  echo "90"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Finalizing docker image"

    # go to the minion and save the machine
    DCFOLDER=${PWD##*/}
    DCHASH=$(doil_get_hash ${DCFOLDER})
    docker commit ${DCHASH} doil/${projectname}:stable
  )

  #################
  # Everything done
  echo "XXX"; echo "Everything done"; echo "XXX"
  echo "100"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Everything done"

    sleep 2
  )
) |
$DIALOG \
  --backtitle "doil - create" \
  --title "doil - create" \
  --gauge "Creating basic folders" 8 50
$DIALOG --clear
$DIALOG \
  --backtitle "doil - create" \
  --title "doil - create" \
  --msgbox "Display endcard ..." 0 0
$DIALOG --clear
clear

