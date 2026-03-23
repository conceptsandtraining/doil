#!/usr/bin/env bash

doil_update_20260323() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias-update-hook/*  /usr/local/share/doil/stack/states/ilias-update-hook/

  return $?
}