#!/usr/bin/env bash

doil_update_20260318() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias/*  /usr/local/share/doil/stack/states/ilias/

  return $?
}