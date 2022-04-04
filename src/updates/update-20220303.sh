#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/../lib/include/system.sh

doil_update_20220303() {

  doil_system_remove_old_version
  doil_system_add_group
  doil_system_create_folder
  doil_system_copy_doil
#  doil_system_setup_config
#  doil_system_setup_ip
#  doil_system_setup_access
#  doil_system_setup_userconfig

	return 0
}