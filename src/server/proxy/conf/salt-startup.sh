#!/bin/bash

# we need to remove the master pub key becase the
# startup of this machine envokes new not accepted
# crypto stuff
rm /var/lib/salt/pki/minion/minion_master.pub