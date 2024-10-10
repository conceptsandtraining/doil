#!/usr/bin/env bash

doil_update_20241010() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/* /usr/local/share/doil/stack/
  docker exec -i doil_saltmain bash -c "salt -C '*.local or *.global' state.highstate saltenv=apache"
  return $?
}