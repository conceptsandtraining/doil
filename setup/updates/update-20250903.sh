#!/usr/bin/env bash

doil_update_20250903() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias/imagemagick/init.sls /usr/local/share/doil/stack/states/ilias/imagemagick/

  return $?
}