#!/usr/bin/env bash

doil_update_20240604() {
  cp ${SCRIPT_DIR}/../app/src/App.php /usr/local/lib/doil/app/src/
  cp ${SCRIPT_DIR}/../app/src/Commands/Instances/CSPCommand.php /usr/local/lib/doil/app/src/Commands/Instances/
  cp ${SCRIPT_DIR}/../setup/stack/states/apache/apache/* /usr/local/share/doil/stack/states/apache/apache/
  cp ${SCRIPT_DIR}/../app/src/Lib/Docker/* /usr/local/lib/doil/app/src/Lib/Docker/
  return $?
}