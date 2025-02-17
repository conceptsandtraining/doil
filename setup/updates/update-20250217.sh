#!/usr/bin/env bash

doil_update_20250217() {
  cp -r ${SCRIPT_DIR}/../setup/stack/* /usr/local/share/doil/stack/
  return $?
}