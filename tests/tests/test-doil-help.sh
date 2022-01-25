#!/usr/bin/env bash

test_doil_display_instances_help() {
  source ./src/lib/include/helper.sh
  asset_string_contains "doil instances - manages the instances" "$(doil_display_help "instances")"
}

test_doil_display_repo_help() {
  source ./src/lib/include/helper.sh
  asset_string_contains "doil repo - manages the repositories" "$(doil_display_help "repo")"
}

test_doil_display_pack_help() {
  source ./src/lib/include/helper.sh
  asset_string_contains "doil pack - exports and imports a doil package" "$(doil_display_help "pack")"
}

test_doil_display_system_help() {
  source ./src/lib/include/helper.sh
  asset_string_contains "doil system - manages the doil system" "$(doil_display_help "system")"
}