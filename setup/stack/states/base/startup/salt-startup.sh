#!/bin/bash

# start cron service
service cron start

# we need to remove the master pub key because the
# startup of this machine invokes new not accepted
# crypto stuff
if [ -f "/etc/salt/pki/minion/minion_master.pub" ]
then
  rm /etc/salt/pki/minion/minion_master.pub
fi


# call the event which calls the script to build the
# configuration for the proxy server
IPADDRESS=$(awk 'END{print $1}' /etc/hosts)
HOSTNAME=$(awk 'END{print $2}' /etc/hosts)
HOSTNAME=${HOSTNAME%".local"}
HOSTNAME=${HOSTNAME%".global"}
salt-call event.send proxy_on_minion_start "{ip: ${IPADDRESS}, hostname: ${HOSTNAME}}"