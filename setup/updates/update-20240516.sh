#!/usr/bin/env bash

doil_update_20240516() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp ${SCRIPT_DIR}/../app/src/Lib/Docker/DockerShell.php /usr/local/lib/doil/app/src/Lib/Docker/
  return $?
}