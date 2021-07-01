#!/bin/bash

source /root/conf/doil.conf
sed -i "s/http:\/\/ilias.local/http:\/\/doil\/${PROJECT_NAME}/g" "/var/ilias/data/ilias-config.json"