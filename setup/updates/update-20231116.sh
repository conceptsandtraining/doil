#!/usr/bin/env bash

source ${SCRIPT_DIR}/updates/update.sh

doil_update_20231116() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp ${SCRIPT_DIR}/../app/src/Lib/Docker/DockerShell.php /usr/local/lib/doil/app/src/Lib/Docker/
  return $?
}