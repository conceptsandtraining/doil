#!/usr/bin/env bash

doil_update_20250523() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/* /usr/local/share/doil/stack/states/
  return $?
}