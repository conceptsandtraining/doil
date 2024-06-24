#!/usr/bin/env bash

doil_update_20240730() {
cat <<EOF

Attention:
Unfortunately, the salt packages from the Debian repos are outdated and errors in salt-key handling occur again and again.
In addition, Debian has been upgraded to version 12 for all containers. So the default PHP version is now 8.2.

So your current doil version cannot be updated. Please remove your current doil version with 'sudo setup/uninstall.sh'
and install the new doil version with 'sudo setup/install.sh'

If the old containers are still needed, they must first be exported using 'doil:pack export' and then imported again
using 'doil pack:import'.

EOF
  return $?
}