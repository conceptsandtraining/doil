#!/usr/bin/env bash

doil_update_20250924() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/

  return $?
}