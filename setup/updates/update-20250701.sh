#!/usr/bin/env bash

doil_update_20250701() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/autoinstall/*  /usr/local/share/doil/stack/states/autoinstall/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/enable-saml/saml/authsources.php.j2  /usr/local/share/doil/stack/states/enable-saml/saml/
  return $?
}