#!/usr/bin/env bash

doil_update_20240926() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/* /usr/local/share/doil/stack/
  return $?
}