#!/usr/bin/env bash

doil_update_20250404() {
  cp -r ${SCRIPT_DIR}/../setup/templates/proxy/conf/nginx/local.conf /usr/local/lib/doil/server/proxy/conf/nginx/local.conf
  doil proxy:restart
  return $?
}