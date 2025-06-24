#!/usr/bin/env bash

doil_update_20250624() {
  cp -r ${SCRIPT_DIR}/../setup/stack/states/ilias-update-hook/update_hook.php.j2 /usr/local/share/doil/stack/states/ilias-update-hook/update_hook.php.j2
  return $?
}