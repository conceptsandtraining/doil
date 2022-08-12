#!/usr/bin/env bash

test_doil_system_remove_old_version() {
  source ./setup/system.sh

  doil_system_remove_old_version
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_add_group() {
  source ./setup/system.sh

  doil_system_add_group
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_create_folder() {
  source ./setup/system.sh

  doil_system_create_folder
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_copy_doil() {
  source ./setup/system.sh

  doil_system_copy_doil
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_config() {
  source ./setup/system.sh

  doil_system_setup_config
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_ip() {
  source ./setup/system.sh

  doil_system_setup_ip
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_access() {
  source ./setup/system.sh

  doil_system_setup_access
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_userconfig() {
  source ./setup/system.sh

  doil_system_setup_userconfig
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}