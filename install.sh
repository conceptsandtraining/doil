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

# Build up local docker images
cd src/lib/tpl/dockerfiles/70
docker build -t catphp70 .
docker tag catphp70:latest

cd ../71
docker build -t catphp71 .
docker tag catphp71:latest

cd ../72
docker build -t catphp72 .
docker tag catphp72:latest

cd ../73
docker build -t catphp73 .
docker tag catphp73:latest
