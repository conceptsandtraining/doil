#!/bin/bash

# set vars
LOST=$@
LOST=${LOST#"["}
LOST=${LOST%"]"}

oIFS=$IFS
IFS=", "

for MINION in ${LOST};
do
	HOSTNAME=${MINION%".local"}
	HOSTNAME=${HOSTNAME%".global"}
	# remove old configuration if present

	if [ -f "/etc/nginx/conf.d/sites/${HOSTNAME}.conf" ]
	then
		rm "/etc/nginx/conf.d/sites/${HOSTNAME}.conf"
		echo "Proxy: ${HOSTNAME} removed"
	fi
done