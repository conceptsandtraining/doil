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
#
# Last revised 2021-mm-dd

# sudo user check
if [ "$EUID" -ne 0 ]
  then echo "Error: Please run this script as sudo-user"
  exit
fi

# check the OS
OPS=""
case "$(uname -s)" in
  Darwin)
    OPS="mac"
  ;;
  Linux)
    OPS="linux"
  ;;
  *)
    echo 'Your system is not supported.' 
    exit
  ;;
esac

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

# say hello
dialog \
  --backtitle "doil - install" \
  --title "doil - install" \
  --msgbox "Thank you for selecting doil as your base of development with ILIAS. Please follow the instructions throughout this installation. Enjoy!" 0 0
$DIALOG --clear
clear

# display the info for the ILIAS repo
dialog \
  --backtitle "doil - install" \
  --title "doil - install" \
  --msgbox "doil comes with the ability to use different sources for your ILIAS installation. In the first step you are provided with the default ILIAS repository from github. You can add repositories later by editing the doil configuration. See README.md for further instructions on this." 0 0
$DIALOG --clear
clear

# set up the name
is_ilias_repo_name=FALSE
while [ ${is_ilias_repo_name} == FALSE ]; do
  exec 3>&1
  ilias_repo_name=$(dialog \
    --backtitle "doil - install" \
    --title "doil - install - (1/5)" \
    --clear \
    --cancel-label "Exit" \
    --inputbox "Set up a name for your ILIAS repository (usually ilias)" ${HEIGHT} ${WIDTH} "ilias" \
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

  if [[ -z "${ilias_repo_name}" ]]
  then
    result="The name of the repository cannot be empty!"
    display_error "Error!"
  elif [[ ${ilias_repo_name} == *['!'@#\$%^\&\(\)*_+]* ]]
  then
    result="You are using an invalid character! Only letters and numbers are allowed!"
    display_error "Error!"
  else
    is_ilias_repo_name=TRUE
    clear
  fi
done

# set up the repo location
is_ilias_repo_location=FALSE
while [ ${is_ilias_repo_location} == FALSE ]; do
  exec 3>&1
  ilias_repo_location=$(dialog \
    --backtitle "doil - install" \
    --title "doil - install - (2/5)" \
    --clear \
    --cancel-label "Exit" \
    --inputbox "Set the location of the github repository." ${HEIGHT} ${WIDTH} "git@github.com:ILIAS-eLearning/ILIAS.git" \
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

  if [[ -z "${ilias_repo_location}" ]]
  then
    result="The name of the repository cannot be empty!"
    display_error "Error!"
  else
    is_ilias_repo_location=TRUE
    clear
  fi
done

# ask for cloning
dialog \
  --backtitle "doil - install" \
  --title "doil - install - (3/5)" \
  --clear \
  --yesno "Do you want to clone this repository through this installation?" ${HEIGHT} ${WIDTH}
ilias_repo_clone=$?
clear
if [[ ${ilias_repo_clone} == 0 ]]
then
  ilias_repo_clone="yes"
else
  ilias_repo_clone="no"
fi

# get the salt repository
is_salt_repo_location=FALSE
while [ ${is_salt_repo_location} == FALSE ]; do
  exec 3>&1
  salt_repo_location=$(dialog \
    --backtitle "doil - install" \
    --title "doil - install - (4/5)" \
    --clear \
    --cancel-label "Exit" \
    --inputbox "Set the location of your salt configuration repository." ${HEIGHT} ${WIDTH} "git@github.com:conceptsandtraining/ilias-tool-salt.git" \
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

  if [[ -z "${salt_repo_location}" ]]
  then
    result="The name of the repository cannot be empty!"
    display_error "Error!"
  else
    is_salt_repo_location=TRUE
    clear
  fi
done

# start the process
DIALOG=dialog
(
  #####################
  # create the log file
  (
    # create log file first
    touch /var/log/doil.log
    chown ${SUDO_USER}:${SODU_USER} "/var/log/doil.log"

    # the send a message there
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Started installing doil"
  )

  ################################
  # Removing old version if needed
  echo "XXX"; echo "Removing old version if needed"; echo "XXX"
  echo "5"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Removing old version if needed"

    # remove the old version of doil because we need to be sure
    # that we are running a clean version here
    if [ $OPS == "linux" ]; then
      if [ -f "/usr/loca/bin/doil" ]; then
        rm /usr/loca/bin/doil
      fi
      if [ -d "/usr/lib/doil" ]; then
        rm -r /usr/lib/doil
      fi
      if [ -f "/usr/share/man/man1/doil.1" ]; then
        rm /usr/share/man/man1/doil.1
      fi
      if [ -f "/usr/share/man/man1/doil.1.gz" ]; then
        rm "/usr/share/man/man1/doil.1.gz"
      fi
    elif [ $OPS == "mac" ]; then
      if [ -f "/usr/local/bin/doil" ]; then
        rm /usr/local/bin/doil
      fi
      if [ -d "/usr/local/lib/doil" ]; then
        rm -rf /usr/local/lib/doil
      fi
    fi
  )

  #########################
  # Copying the doil system
  echo "XXX"; echo "Copying the doil system"; echo "XXX"
  echo "15"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Copying the doil system"


    # Move the base script to the /usr/local/bin folder and make it executeable
    cp src/doil.sh /usr/local/bin/doil
    chmod a+x /usr/local/bin/doil

    # Move the script library to /usr/lib/doil
    if [ $OPS == "linux" ]; then
      if [ ! -d "/usr/lib/doil" ]
      then
        mkdir /usr/lib/doil
      fi
      cp -r src/lib/* /usr/lib/doil
      chmod -R 777 /usr/lib/doil/tpl/
      chmod a+x /usr/lib/doil/*.sh
    elif [ $OPS == "mac" ]; then
      if [ ! -d "/usr/local/lib/doil" ]
      then
        mkdir /usr/local/lib/doil
      fi
      cp -r src/lib/* /usr/local/lib/doil
      chmod -R 777 /usr/local/lib/doil/tpl/
      chmod a+x /usr/local/lib/doil/*.sh
    fi
  )

  ####################
  # Installing manpage
  echo "XXX"; echo "Installing manpage"; echo "XXX"
  echo "20"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Installing manpage"

    if [ $OPS == "linux" ]; then
      install -g 0 -o 0 -m 0644 src/man/doil.1 /usr/share/man/man1/
      gzip /usr/share/man/man1/doil.1
    elif [ $OPS == "mac" ]; then
      # TODO THIS!
      echo "Manpage for mac is currently not supported..."
    fi
  )

  ################################
  # Setting up local configuration
  echo "XXX"; echo "Setting up local configuration"; echo "XXX"
  echo "30"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Setting up local configuration"

    # setup local doil folder
    HOME=$(eval echo "~${SUDO_USER}")
    if [ ! -d "${HOME}/.doil" ]
    then
      mkdir "${HOME}/.doil"
    fi

    # setup the local configuration for the repos and the stack
    if [ ! -d "${HOME}/.doil/config" ]
    then
      mkdir "${HOME}/.doil/config"
    fi

    touch "${HOME}/.doil/config/repos"
    touch "${HOME}/.doil/config/saltstack"

    # for the user
    chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"

    # echo configuration
    echo "${ilias_repo_name}=${ilias_repo_location}" >> "${HOME}/.doil/config/repos"
    echo "${salt_repo_location}" >> "${HOME}/.doil/config/saltstack"
  )

  ###########################
  # Cloning ILIAS (if needed)
  if [[ ${ilias_repo_clone} == "yes" ]]
  then
    echo "XXX"; echo "Cloning ILIAS"; echo "XXX"
    echo "50"
    (
      # log file
      readonly LOG_FILE="/var/log/doil.log"
      exec 1>>${LOG_FILE}
      exec 2>&1
      NOW=$(date +'%d.%m.%Y %I:%M:%S')
      echo "[${NOW}] Cloning ILIAS"

    # Note: Sorry for the intendation here. I really don't know
    # how I could fix this and make this pretty.
    if [ $OPS == "linux" ]; then
sudo -i -u $SUDO_USER bash << EOF
git clone ${gprojecttyperepo} "/usr/lib/doil/tpl/repo/${projecttype}"
EOF
    elif [ $OPS == "mac" ]; then
sudo -i -u $SUDO_USER bash << EOF
git clone ${gprojecttyperepo} "/usr/local/lib/doil/tpl/repo/${projecttype}"
EOF
    fi

    )
  fi

  ############################
  # Cloning salt configuration
  echo "XXX"; echo "Cloning salt configuration"; echo "XXX"
  echo "75"
  (
    # log file
    readonly LOG_FILE="/var/log/doil.log"
    exec 1>>${LOG_FILE}
    exec 2>&1
    NOW=$(date +'%d.%m.%Y %I:%M:%S')
    echo "[${NOW}] Cloning salt configuration"

    # Note: Sorry for the intendation here. I really don't know
    # how I could fix this and make this pretty.
    if [ $OPS == "linux" ]; then
sudo -i -u $SUDO_USER bash << EOF
git clone git@github.com:conceptsandtraining/ilias-tool-salt.git /usr/lib/doil/tpl/stack
EOF
    elif [ $OPS == "mac" ]; then
sudo -i -u $SUDO_USER bash << EOF
git clone git@github.com:conceptsandtraining/ilias-tool-salt.git /usr/local/lib/doil/tpl/stack
EOF
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
  --backtitle "doil - install" \
  --title "doil - install" \
  --gauge "Creating log file" 8 50
$DIALOG --clear
$DIALOG \
  --backtitle "doil - install" \
  --title "doil - install" \
  --msgbox "doil has been installed successfully. See 'man doil' for more information about the usage of doil. See README.md in this folder for more information about the configuration. You can also delete this folder now. Thank you!" 0 0
$DIALOG --clear
clear
