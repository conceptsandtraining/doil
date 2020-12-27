#!/bin/bash

# sudo user check
if [ "$EUID" -ne 0 ]
  then echo "Error: Please run this script as sudo-user"
  exit
fi

# check if dialog is installed on this system
case "$(uname -s)" in
  Darwin)
    brew install dialog
  ;;
  Linux)
    apt-get install dialog
  ;;
  CYGWIN*|MINGW32*|MSYS*|MINGW*)
    echo 'MS Windows'
  ;;
  *)
    echo 'Other OS' 
    exit
  ;;
esac

# remove the old version of doil because we need to be sure
# that we are running a clean version here
rm /usr/loca/bin/doil
rm -r /usr/lib/doil

# Move the base script to the /usr/local/bin folder and make it executeable
cp src/doil.sh /usr/local/bin/doil
chmod a+x /usr/local/bin/doil

# Move the script library to /usr/lib/doil
if [ ! -d "/usr/lib/doil" ]
then
  mkdir /usr/lib/doil
fi
cp -r src/lib/* /usr/lib/doil
chmod -R 777 /usr/lib/doil/tpl/
chmod a+x /usr/lib/doil/*.sh

# install the manpage
install -g 0 -o 0 -m 0644 src/man/doil.1 /usr/share/man/man1/
gzip /usr/share/man/man1/doil.1

# Install local instance tracker
HOME=$(eval echo "~${SUDO_USER}")
if [ ! -d "${HOME}/.doil" ]
then
  mkdir "${HOME}/.doil"
  chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil"
fi

# setup the local configuration for the repos and the stack
if [ ! -d "${HOME}/.doil/config" ]
then
  mkdir "${HOME/.doil/config}"
  chown -R ${SUDO_USER}:${SODU_USER} "${HOME}/.doil/config"
fi
echo "ilias=git@github.com:ILIAS-eLearning/ILIAS.git" >> "${HOME}/.doil/config/repos"
echo "cate=git@github.com:conceptsandtraining/TMS6.git" >> "${HOME}/.doil/config/repos"
echo "git@github.com:conceptsandtraining/ilias-tool-salt.git" >> "${HOME}/.doil/config/saltstack"

# clone the basic repositories
sudo -i -u $SUDO_USER bash << EOF
git clone git@github.com:conceptsandtraining/TMS6.git /usr/lib/doil/tpl/repo/cate
git clone git@github.com:ILIAS-eLearning/ILIAS.git /usr/lib/doil/tpl/repo/ilias
git clone git@github.com:conceptsandtraining/ilias-tool-salt.git /usr/lib/doil/tpl/stack
EOF
