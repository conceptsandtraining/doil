#!/bin/bash

source /root/conf/doil.conf
sed -i "s/%DOMAIN%/${PROJECT_NAME}/g" "/etc/apache2/sites-available/000-default.conf"