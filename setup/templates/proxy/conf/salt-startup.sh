#!/bin/bash

# we need to remove the master pub key because the
# startup of this machine invokes new not accepted
# crypto stuff
if [ -f "/var/lib/salt/pki/minion/minion_master.pub" ]
then
  rm /var/lib/salt/pki/minion/minion_master.pub
fi

pgrep salt-minion
if [[ "$1" != "0" ]]
then
  killall -9 salt-minion &>/dev/null
fi
/etc/init.d/salt-minion restart
