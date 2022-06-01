#!/bin/bash

# start cron service
service cron start

# we need to remove the master pub key becase the
# startup of this machine envokes new not accepted
# crypto stuff
rm /var/lib/salt/pki/minion/minion_master.pub

# call the event which calls the script to build the
# configuration for the proxy server
IPADDRESS=$(awk 'END{print $1}' /etc/hosts)
HOSTNAME=$(awk 'END{print $2}' /etc/hosts)
HOSTNAME=${HOSTNAME%".local"}
HOSTNAME=${HOSTNAME%".global"}
salt-call event.send proxy_on_minion_start "{ip: ${IPADDRESS}, hostname: ${HOSTNAME}}"