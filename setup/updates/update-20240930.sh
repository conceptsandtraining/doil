#!/usr/bin/env bash

doil_update_20240930() {
  cp ${SCRIPT_DIR}/../app/src/Commands/Pack/ImportCommand.php /usr/local/lib/doil/app/src/Commands/Pack/
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/* /usr/local/share/doil/stack/
  doil salt:restart
  return $?
}