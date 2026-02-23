#!/usr/bin/env bash

doil_update_20250223() {
  cp -r ${SCRIPT_DIR}/../app/src/* /usr/local/lib/doil/app/src/
  cp -r ${SCRIPT_DIR}/../setup/stack/states/enable-saml/saml/SetIdpV10.php.j2  /usr/local/share/doil/stack/enable-saml/saml/SetIdpV10.php.j2

  return $?
}