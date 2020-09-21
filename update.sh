#!/bin/bash

# Move the base script to the /usr/local/bin folder
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
chmod a+x /usr/lib/doil/tms/*.sh
chmod a+x /usr/lib/doil/tpl/docker-configs/*.sh
chmod a+x /usr/lib/doil/tpl/lucene/*.sh

# INSTALL MANPAGE
install -g 0 -o 0 -m 0644 src/man/doil.1 /usr/share/man/man1/
gzip /usr/share/man/man1/doil.1

# Install local instance tracker
HOME=$(eval echo "~${SUDO_USER}")
if [ ! -d "$HOME/.doil" ]
then
  mkdir "$HOME/.doil"
  chown -R $SUDO_USER:$SODU_USER "$HOME/.doil"
fi

if [ ! -d "$HOME/.doil/config" ]
then
	mkdir "$HOME/.doil/config"
	touch "$HOME/.doil/config/subnetcounter"
	echo "20" > "$HOME/.doil/config/subnetcounter"
	chown -R $SUDO_USER:$SODU_USER "$HOME/.doil"
fi
