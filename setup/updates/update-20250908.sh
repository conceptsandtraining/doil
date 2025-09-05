#!/usr/bin/env bash

doil_update_20250908() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/mailservices/mailservices/*  /usr/local/share/doil/stack/states/mailservices/mailservices/

  return $?
}