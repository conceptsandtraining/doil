#!/bin/bash

# we need to remove the master pub key because the
# startup of this machine invokes new not accepted
# crypto stuff
if [ -f "/var/lib/salt/pki/minion/minion_master.pub" ]
then
  rm /var/lib/salt/pki/minion/minion_master.pub
fi