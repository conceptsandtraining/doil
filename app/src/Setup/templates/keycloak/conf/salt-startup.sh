#!/bin/bash

# we need to remove the master pub key because the
# startup of this machine invokes new not accepted
# crypto stuff
if [ -f "/etc/salt/pki/minion/minion_master.pub" ]
then
  rm /etc/salt/pki/minion/minion_master.pub
fi

while ! pgrep -f "mariadb" > /dev/null; do
    sleep 1
done

if [ -f "/root/init.sql" ]
then
  mysql < /root/init.sql
  rm /root/init.sql
fi