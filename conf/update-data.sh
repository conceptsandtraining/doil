#!/bin/bash

# Config
DATABASE_SERVER="172.24.2.21"
ILIAS_CLIENT_NAME="cattms"
ILIAS_DATA_FOLDER="/var/www/html/ilias/data/{$ILIAS_CLIENT_NAME}"

# Make backup of data and clone the live data
cd /var/www/html/ilias/data
rm -rf "${ILIAS_CLIENT_NAME}_bak"
rm data.tar.gz
mv $ILIAS_CLIENT_NAME "${ILIAS_CLIENT_NAME}_bak"
mkdir $ILIAS_CLIENT_NAME
wget https://ilias1.cat06.de/testcaser/downloadtest/data.tar.gz
#wget https://ilias1.cat06.de/backupdata/data.tar.gz
tar xfvz data.tar.gz $ILIAS_CLIENT_NAME
rm data.tar.gz

# TODO Clone database
