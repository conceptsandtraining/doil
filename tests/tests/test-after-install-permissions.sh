#!/usr/bin/env bash

test_etc_doil_should_be_writeable() {
  assert_equals "drwxrwsr-x" "$(./tests/after-install/permissions-folder.sh "/etc/doil")"
}

test_templates_should_be_writeable() {
  assert_equals "drwxrwsr-x" "$(./tests/after-install/permissions-folder.sh "/usr/local/share/doil/templates")"
}

test_repositories_should_be_writeable() {
  assert_equals "drwxrwsr-x" "$(./tests/after-install/permissions-folder.sh "/usr/local/share/doil/repositories")"
}

test_instances_should_be_writeable() {
  assert_equals "drwxrwsr-x" "$(./tests/after-install/permissions-folder.sh "/usr/local/share/doil/instances")"
}