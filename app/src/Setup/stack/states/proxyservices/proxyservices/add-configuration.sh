#!/bin/bash

# set vars
IP=${1}
HOSTNAME=${2}

# remove old configuration if present
if [ -f "/etc/nginx/conf.d/sites/${HOSTNAME}.conf" ]
then
	rm "/etc/nginx/conf.d/sites/${HOSTNAME}.conf"
fi

# copy template
cp "/root/service-config.tpl" "/etc/nginx/conf.d/sites/${HOSTNAME}.conf"
sed -i "s/%IP%/${IP}/g" "/etc/nginx/conf.d/sites/${HOSTNAME}.conf"
sed -i "s/%DOMAIN%/${HOSTNAME}/g" "/etc/nginx/conf.d/sites/${HOSTNAME}.conf"

# reload configuration
/etc/init.d/nginx reload