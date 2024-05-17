#!/usr/bin/env bash

doil_update_20240517() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp ${SCRIPT_DIR}/../app/src/Commands/Pack/ExportCommand.php /usr/local/lib/doil/app/src/Commands/Pack/
  cp ${SCRIPT_DIR}/../app/src/Lib/FileSystem/* /usr/local/lib/doil/app/src/Lib/FileSystem/
  return $?
}