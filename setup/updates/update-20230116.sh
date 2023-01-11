#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source ${SCRIPT_DIR}/../system.sh
source ${SCRIPT_DIR}/../log.sh

doil_update_20230116() {
  doil_status_send_message_nl "Stopping all services"
  doil_system_stop_all_services

  doil_status_send_message "Removing old doil services"
  doil_system_remove_services

  doil_status_send_message_nl "Removing old doil system"
  doil_system_remove_old_version
  doil_status_okay

  doil_status_send_message "Copying new doil system"
  doil_system_create_folder
  doil_system_copy_doil
  doil_status_okay

  doil_status_send_message "Run composer"
  doil_system_run_composer
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    exit
  fi
  doil_status_okay

  doil_status_send_message "Setting up access rights"
  doil_system_setup_access
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    exit
  fi
  doil_status_okay

  doil_status_send_message "Reinstalling salt service"
  doil_system_install_saltserver
  doil_status_okay

  doil_status_send_message "Reinstalling proxy service"
  doil_system_install_proxyserver
  doil_status_okay

  doil_status_send_message "Installing mail service"
  doil_system_install_mailserver
  doil_status_okay

	return 0
}