#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20231115() {
  update
  return $?
}
