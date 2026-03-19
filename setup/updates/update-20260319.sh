#!/usr/bin/env bash

doil_update_20260319() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/apache/*  /usr/local/share/doil/stack/states/apache/

  return $?
}