#!/usr/bin/env bash

doil_update_20250725() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/autoinstall/autoinstall/init.sls /usr/local/share/doil/stack/states/autoinstall/autoinstall/
  return $?
}