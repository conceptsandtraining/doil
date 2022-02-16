#!/usr/bin/env bash

test_doil_perform_update() {
  source ./src/lib/include/helper.sh
  source ./src/lib/include/log.sh
  assert_string_contains "" "$(doil_perform_update)"
}

test_doil_system_remove_old_version() {
  source ./src/lib/include/system.sh

  doil_system_remove_old_version
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_add_group() {
  source ./src/lib/include/system.sh

  doil_system_add_group
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_create_folder() {
  source ./src/lib/include/system.sh

  doil_system_create_folder
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_copy_doil() {
  source ./src/lib/include/system.sh

  doil_system_copy_doil
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_config() {
  source ./src/lib/include/system.sh

  doil_system_setup_config
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_ip() {
  source ./src/lib/include/system.sh

  doil_system_setup_ip
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_access() {
  source ./src/lib/include/system.sh

  doil_system_setup_access
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_setup_userconfig() {
  source ./src/lib/include/system.sh

  doil_system_setup_userconfig
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_system_touch_log_file() {
  source ./src/lib/include/system.sh

  doil_system_touch_log_file
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

