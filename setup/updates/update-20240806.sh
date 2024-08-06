#!/usr/bin/env bash

doil_update_20240806() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp ${SCRIPT_DIR}/../app/src/Commands/Instances/CreateCommand.php /usr/local/lib/doil/app/src/Commands/Instances/
  cp ${SCRIPT_DIR}/../app/src/Commands/Pack/PackCreateCommand.php /usr/local/lib/doil/app/src/Commands/Pack/
  cp ${SCRIPT_DIR}/../setup/stack/states/nodejs/nodejs/* /usr/local/share/doil/stack/states/nodejs/nodejs/
  return $?
}