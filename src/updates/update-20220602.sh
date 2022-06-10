#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/../lib/include/system.sh
source ${SCRIPT_DIR}/../lib/include/log.sh
source ${SCRIPT_DIR}/colors.sh

doil_update_20220602() {

  doil_status_send_message "Stopping all services"
  doil_system_stop_all_services
  doil_status_okay

  doil_status_send_message "Removing old doil services"
  doil_system_remove_services
  doil_status_okay

  doil_status_send_message "Removing old doil system"
  doil_system_remove_old_version
  doil_status_okay

  doil_status_send_message "Copying doil new system"
  doil_system_create_folder
  doil_system_copy_doil
  doil_status_okay

  doil_status_send_message "Reinstalling salt service"
  doil_system_replace_salt_stack
  doil system:salt start
  doil_status_okay

  doil_status_send_message "Reinstalling proxy service"
  doil_system_install_proxyserver
  doil_status_okay

  doil_status_send_message "Installing mail service"
  doil_system_install_mailserver
  doil_status_okay

	return 0
}