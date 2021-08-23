#!/bin/bash

groupdel doil
rm -rf /var/log/doil.log
rm -rf /etc/doil/
rm -rf /usr/local/lib/doil
rm -rf /usr/local/share/doil
rm -rf /usr/local/bin/doil

HOME=$(eval echo "~${SUDO_USER}")
rm -rf ${HOME}/.doil