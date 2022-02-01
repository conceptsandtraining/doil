#!/usr/bin/env bash

test_doil_maybe_display_help() {
  source ./src/lib/include/helper.sh
  assert_string_contains "doil - ILIAS docker tool" "$(doil_maybe_display_help)"
}

test_doil_maybe_display_help_with_parameter() {
  source ./src/lib/include/helper.sh
  assert_string_contains "doil instances - manages the instances" "$(doil_maybe_display_help "instances")"
}