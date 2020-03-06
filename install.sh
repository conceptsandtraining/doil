#!/bin/bash

# Move the base script to the /usr/local/bin folder
cp src/doil.sh /usr/local/bin/doil
chmod a+x /usr/local/bin/doil

# Move the script library to /usr/lib/doil
cp -r src/lib/* /usr/lib/doil
chmod -R 777 /usr/lib/doil/tpl/repos/

# INSTALL MANPAGE
#install -g 0 -o 0 -m 0644 src/man/doil.1 /usr/share/man/man1/
#gzip /usr/share/man/man1/doil.1

# Install local instance tracker
#read -p "Please type your username for this machine: " username
#if [ ! -d "/home/$username/.doil" ]
#then
#  mkdir "/home/$username/.doil"
#  chown -R $username:$username "/home/$username/.doil"
#fi
