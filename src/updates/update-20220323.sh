#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/../lib/include/system.sh

doil_update_20220323() {

  doil_system_remove_old_version
  doil_system_create_folder
  doil_system_copy_doil
#  doil_system_replace_salt_stack
#  doil_system_install_mailserver

	return 0
}