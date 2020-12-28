#!/bin/bash

# set the doilpath
case "$(uname -s)" in
  Darwin)
    HOS="mac"
    DOILPATH="/usr/local/lib/doil"
  ;;
  Linux)
    HOS="linux"
    DOILPATH="/usr/lib/doil"
  ;;
  *)
    exit
  ;;
esac
source "${DOILPATH}/helper.sh"

# Get the settings
CWD=$(pwd)

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
    --title "doil - create - (1/5)" \
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
      echo "Program aborted with: ${exit_status}" >&2
      exit 1
    ;;
  esac

  LINKPATH="${HOME}/.doil/${projectname}"
  if [[ -z "${projectname}" ]]
  then
    result="The name of the project cannot be empty!"
    display_error "Error!"
  elif [[ ${projectname} == *['!'@#\$%^\&\(\)*_+]* ]]
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
done < "${HOME}/.doil/config/repos"

while [ ${is_projecttype} == FALSE ]; do
  exec 3>&1
  projecttype=$(dialog \
    --backtitle "doil - create" \
    --title "doil - create - (2/5)" \
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
      echo "Program aborted with: ${exit_status}" >&2
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
if [ ! -d "${DOILPATH}/tpl/repo/${projecttype}" ]
then

  while read line
  do
    gprojecttypename="$(cut -d'=' -f1 <<<${line})"
    gprojecttyperepo="$(cut -d'=' -f2 <<<${line})"

    if [ $gprojecttypename = $projecttype ]
    then
      break
    fi
  done < "${HOME}/.doil/config/repos"
  git clone ${gprojecttyperepo} "${DOILPATH}/tpl/repo/${projecttype}"
fi
cd "${DOILPATH}/tpl/repo/${projecttype}"
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
    --title "doil - create - (3/5)" \
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
      echo "Program aborted with: ${exit_status}" >&2
      exit 1
    ;;
  esac
  is_projectbranch=TRUE
  clear
done

# get the php version
is_projectphpversion=FALSE
while [ ${is_projectphpversion} == FALSE ]; do
  exec 3>&1
  projectphpversion=$(dialog \
    --backtitle "doil - create" \
    --title "doil - create - (4/5)" \
    --clear \
    --cancel-label "Exit" \
    --menu "Set the branch for your project" ${HEIGHT} ${WIDTH} "" \
      "7.0" "PHP Version 7.0" \
      "7.1" "PHP Version 7.1" \
      "7.2" "PHP Version 7.2" \
      "7.3" "PHP Version 7.3" \
      "7.4" "PHP Version 7.4" \
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
      echo "Program aborted with: ${exit_status}" >&2
      exit 1
    ;;
  esac
  is_projectphpversion=TRUE
  clear
done

# ask for state if we can't determine it automatically
if [[ ${projecttype} != "cate" ]] && [[ ${projectbranch} != "release_5-4" ]] && [[ ${projectbranch} != "release_6" ]] && [[ ${projectbranch} != "release_7" ]]
then
  is_projectstate=FALSE
  while [ ${is_projectstate} == FALSE ]; do
    exec 3>&1
    projectstate=$(dialog \
      --backtitle "doil - create" \
      --title "doil - create - (4.5/5)" \
      --clear \
      --cancel-label "Exit" \
      --menu "doil can't determine the corrent ILIAS version. Could you please specify it by chosing the corrent base version of ILIAS?" ${HEIGHT} ${WIDTH} "" \
        "ilias54" "ILIAS Version 5.4" \
        "ilias6" "ILIAS Version 6.x" \
        "ilias7" "ILIAS Version 7.x" \
        "cate" "cate" \
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
        echo "Program aborted with: ${exit_status}" >&2
        exit 1
      ;;
    esac
    is_projectstate=TRUE
    clear
  done
fi

# ask for autoinstaller
dialog \
  --backtitle "doil - create" \
  --title "doil - create - (5/5)" \
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

# set the most important var
FOLDERPATH="${CWD}/${projectname}"

# start the process
DIALOG=dialog
(
  ##########################
  # create the basic folders
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Start creating project ${projectname}"
    echo "[${NOW}] Create basic folders"
  
    mkdir -p "${FOLDERPATH}/conf"
    mkdir -p "${FOLDERPATH}/volumes/db"
    mkdir -p "${FOLDERPATH}/volumes/index"
    mkdir -p "${FOLDERPATH}/volumes/data"
    mkdir -p "${FOLDERPATH}/volumes/logs/error"
    mkdir -p "${FOLDERPATH}/volumes/logs/apache"

    # set the link
    ln -s "${FOLDERPATH}" "${HOME}/.doil/${projectname}"
  )

  #########################
  # Copying necessary files
  echo "XXX"; echo "Copying necessary files"; echo "XXX"
  echo "5"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Copying necessary files"

    # docker stuff
    cp "${DOILPATH}/tpl/minion/run-supervisor.sh" "${FOLDERPATH}/conf/run-supervisor.sh"
    cp "${DOILPATH}/tpl/minion/docker-compose.yml" "${FOLDERPATH}/docker-compose.yml"
    cp "${DOILPATH}/tpl/minion/Dockerfile" "${FOLDERPATH}/Dockerfile"

    # copy ilias
    cd "${DOILPATH}/tpl/repo/${projecttype}"
    git config core.fileMode false
    git fetch origin
    git checkout ${projectbranch}
    git pull origin ${projectbranch}
    cp -r "${DOILPATH}/tpl/repo/${projecttype}" "${FOLDERPATH}/volumes/ilias"
  )

  ############################
  # replace the templates vars
  echo "XXX"; echo "Replacing templates vars"; echo "XXX"
  echo "9"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Replacing template vars"

    # replacer
    if [ ${HOS} == "linux" ]; then
      find "${FOLDERPATH}" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%TPL_PROJECT_NAME%/${projectname}/g"
      find "${FOLDERPATH}" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/%DOILPATH%/${DOILPATH}/g"
    elif [ ${HOS} == "mac" ]; then
      sed -i "" "s/%TPL_PROJECT_NAME%/${projectname}/g" "${FOLDERPATH}/docker-compose.yml"
      sed -i "" "s/%DOILPATH%/\/usr\/local\/lib\/doil/g" "${FOLDERPATH}/docker-compose.yml"
    fi
  )

  ##############################
  # starting master salt service
  echo "XXX"; echo "Starting master salt service"; echo "XXX"
  echo "10"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Starting master salt service"

    # start service
    cd ${DOILPATH}/tpl/main
    docker-compose up -d
    sleep 5
  )

  ##############################
  # checking master salt service
  echo "XXX"; echo "Checking master salt service"; echo "XXX"
  echo "17"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Checking master salt service"

    # check if the salt-master service is running the service
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}

    DCMAINSALTSERVICE=$(docker exec -ti ${DCMAINHASH} bash -c "ps -aux | grep salt-master" | grep "/usr/bin/salt-master -d")
    if [[ -z ${DCMAINSALTSERVICE} ]]
    then
      $(docker exec -ti ${DCMAINHASH} bash -c "salt-master -d")
      sleep 5
    fi

    until [[ ! -z ${DCMAINSALTSERVICE} ]]
    do
      echo "Master service not ready ..."
      sleep 0.1
    done
    echo "Master service ready."
  )

  #######################
  # building minion image
  echo "XXX"; echo "Building minion image"; echo "XXX"
  echo "20"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Building minion image"

    # build the image
    cd ${FOLDERPATH}
    docker-compose up --force-recreate --no-start --renew-anon-volumes
  )

  ##############################
  # starting salt minion service
  echo "XXX"; echo "Starting salt minion service"; echo "XXX"
  echo "30"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Starting salt minion service"

    # start the docker service
    cd ${FOLDERPATH}
    docker-compose up -d
    sleep 5
  )

  ##############################
  # checking minion service
  echo "XXX"; echo "Checking minion service"; echo "XXX"
  echo "35"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Checking minion service"

    # check if the service is running
    cd ${FOLDERPATH}
    DCMINIONFOLDER=${PWD##*/}
    DCMINIONHASH=$(doil_get_hash ${DCMINIONFOLDER})
    DCMINIONSALTSERVICE=$(docker container top ${DCMINIONHASH} | grep "salt-minion")

    # wait until the service is there
    if [[ ! -z ${DCMINIONSALTSERVICE} ]]
    then
      echo "Minion service not ready ... starting"
      docker exec -ti ${DCMINIONHASH} bash -c "salt-minion -d"
      sleep 5
    fi

    # check if the new key is registered
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}
    SALTKEYS=$(docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt-key -L" | grep "${projectname}.local")

    if [ ! -z ${SALTKEYS} ]
    then
      docker exec -ti ${DCMAINHASH} bash -c "killall -9 salt-master"
      sleep 5
      docker exec -ti ${DCMAINHASH} bash -c "salt-master -d"
      sleep 7
    fi
    echo "Key ready."
  )

  ##################
  # apply base state
  echo "XXX"; echo "Apply base state"; echo "XXX"
  echo "40"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%D.%M.%Y %I:%M:%S')
    echo "[${NOW}] Apply base state"

    # apply base state
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}
    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=base --state-output=terse"
  )

  #################
  # apply dev state
  echo "XXX"; echo "Apply dev state"; echo "XXX"
  echo "60"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Apply dev state"

    # apply base state
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}
    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=dev --state-output=terse"
  )

  #################
  # apply php state
  echo "XXX"; echo "Apply php state"; echo "XXX"
  echo "65"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Apply php state"

    # apply base state
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}

    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=php${projectphpversion} --state-output=terse"
  )

  ###################
  # apply ilias state
  echo "XXX"; echo "Apply ilias state"; echo "XXX"
  echo "70"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Apply ilias state"

    # apply base state
    DCMAIN=$(docker ps | grep "saltmain")
    DCMAINHASH=${DCMAIN:0:12}

    if [[ -z ${projectstate} ]]
    then
      if [[ ${projecttype} == "cate" ]]
      then
        projectstate="cate"
      elif [[ ${projectbranch} == "release_5-4" ]]
      then
        projectstate="ilias54"
      elif [[ ${projectbranch} == "release_6" ]]
      then
        projectstate="ilias6"
      elif [[ ${projectbranch} == "release_7" ]]
      then
        projectstate="ilias7"
      fi
    fi

    docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=${projectstate} --state-output=terse"
  )

  ###############################
  # apply autoinstaller if needed
  if [[ ${projectautoinstall} == "yes" ]]
  then
    echo "XXX"; echo "Trying auto installation"; echo "XXX"
    echo "80"
    (
      # log file
      readonly LOG_FILE="/var/log/doil.log"
      exec 1>>${LOG_FILE}
      exec 2>&1
      NOW=$(date +'%d.%m.%Y %I:%M:%S')
      echo "[${NOW}] Trying auto installation"

      # apply base state
      DCMAIN=$(docker ps | grep "saltmain")
      DCMAINHASH=${DCMAIN:0:12}

      projectaiinstallstate=FALSE
      if [[ ${projecttype} == "cate" ]]
      then
        projectaiinstallstate="cate_ai"
      elif [[ ${projectbranch} == "release_6" ]]
      then
        projectaiinstallstate="ilias6_ai"
      elif [[ ${projectbranch} == "release_7" ]]
      then
        projectaiinstallstate="ilias7_ai"
      fi

      if [ ${projectaiinstallstate} != FALSE ]
      then
        docker exec -t -i ${DCMAINHASH} /bin/bash -c "salt '${projectname}.local' state.highstate saltenv=${projectaiinstallstate} --state-output=terse"
      fi
    )
  fi

  #########################
  # finalizing docker image
  echo "XXX"; echo "Finalizing docker image"; echo "XXX"
  echo "90"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Finalizing docker image"

    # go to the minion and save the machine
    cd ${FOLDERPATH}
    DCFOLDER=${PWD##*/}
    DCHASH=$(doil_get_hash ${DCFOLDER})
    docker commit ${DCHASH} doil/${projectname}:stable

    # stop the server
    doil down
  )

  ###########################
  # Copying readme to project
  echo "XXX"; echo "Copying readme to project"; echo "XXX"
  echo "99"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Copying readme to project"

    cp "${DOILPATH}/tpl/minion/README.md" "${FOLDERPATH}/README.md"
    if [ ${HOS} == "linux" ]; then
      sed -i "s/%TPL_PROJECT_NAME%/${projectname}/g" "${FOLDERPATH}/README.md"
    elif [ ${HOS} == "mac" ]; then
      sed -i "s/%TPL_PROJECT_NAME%/${projectname}/g" "${FOLDERPATH}/README.md"
    fi
  )

  #################
  # Everything done
  echo "XXX"; echo "Everything done"; echo "XXX"
  echo "100"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
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
  --msgbox "Your project is successfully installed. Head to your project via 'doil cd ${projectname}' and see the readme file for more information about the usage with doil." 0 0
$DIALOG --clear
clear

