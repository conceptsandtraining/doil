#!/usr/bin/env bash

update() {
  doil_status_send_message_nl "Stopping all services"
  doil_system_stop_instances

  doil_status_send_message "Removing old doil system"
  doil_system_remove_old_version
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    exit
  fi
  doil_status_okay

  doil_status_send_message "Copying new doil system"
  doil_system_create_folder
  doil_system_copy_doil
  doil_status_okay

  doil_status_send_message "Creating log file"
  doil_system_setup_log
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

  doil_status_send_message "Stopping all doil instances"
  doil_system_stop_instances
  doil_status_okay

  doil_status_send_message "Removing doil system instances"
  doil_system_rm_system_instances
  doil_status_okay

  doil_status_send_message "Removing old doil images"
  doil_system_remove_doil_system_images
  doil_status_okay

  doil_status_send_message "Copying new doil system"
  doil_system_create_folder
  doil_system_copy_doil
  doil_status_okay

  doil_status_send_message "Adding safe git dir for user"
  doil_system_add_safe_git_dir
  if [[ $? -ne 0 ]]
  then
    doil_status_failed
    exit
  fi
  doil_status_okay

  doil_status_send_message "Deleting potential composer lock file"
  doil_system_delete_potential_composer_lock
  doil_status_okay

  doil_status_send_message "Building doil php image"
  doil_system_build_php_image
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

  doil_status_send_message "Reinstalling mail service"
  doil_system_install_mailserver
  doil_status_okay

	return 0
}