#!/usr/bin/env bash

test_group_doil_should_exist() {
  assert_equals "doil" "$(./tests/after-install/get-all-groups.sh)"
}

test_user_should_be_in_group_doil() {
  assert_contains "doil" "$(./tests/after-install/get-user-groups.sh)"
}

test_user_should_be_in_group_sudo() {
  assert_contains "sudo" "$(./tests/after-install/get-user-groups.sh)"
}
