#!/usr/bin/env bash

# tstfy is a bash unit test suite
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/tstfy
#
#                    .-.
#                   / /
#                  / |
#    |\     ._ ,-""  `.
#    | |,,_/  7        ;
#  `;=     ,=(     ,  /
#   |`q  q  ` |    \_,|
#  .=; <> _ ; /  ,/'/ |
# ';|\,j_ \;=\ ,/   `-'
#     `--'_|\  )
#    ,' | /  ;'
#   (,,/ (,,/      Thanks to Concepts and Training for supporting tstfy

# Setup local variables
TEST_STATUS=TRUE
CAT="$(which cat)"
SED="$(which sed)"
GREP="$(which grep)"
RM="$(which rm)"

# asserts
_assert_expression() {
  local ASSERTION=$1
  local CONDITION=$2
  local MESSAGE=$3
  (
    local STDOUT=$(mktemp)
    local STDERR=$(mktemp)
    trap "$RM  -f \"${STDOUT}\" \"${STDERR}\"" EXIT

    local STATUS
    eval "(${ASSERTION})" >"${STDOUT}" 2>"${STDERR}" && STATUS=$? || STATUS=$?

    if ! eval "${CONDITION}"
    then
      echo -n "FAILURE"
      echo -e "\n\t\t${MESSAGE}"
      return 1
    fi
  ) || return $?
}

assert() {
  local ASSERTION=$1
  local MESSAGE=${2:-}

  _assert_expression \
    "${ASSERTION}" \
    "[ \${STATUS} == 0 ]" \
    "\"${MESSAGE}\""
}

assert_equals() {
  local EXPECTED=$1
  local ACTUAL=$2
  
  if [ "${EXPECTED}" != "${ACTUAL}" ]
  then
    echo -n "FAILURE"
    echo -e "\n\t\texpected [${EXPECTED}] but was [${ACTUAL}]"
    return 1
  fi
}

assert_not_equals() {
  local EXPECTED=$1
  local ACTUAL=$2
  
  if [ "${EXPECTED}" == "${ACTUAL}" ]
  then
    echo -n "FAILURE"
    echo -e "\n\t\texpected [${EXPECTED}] to be different but is equal to [${ACTUAL}]"
    return 1
  fi
}

assert_fails() {
  local ASSERTION=$1
  local MESSAGE=${2:-}

  _assert_expression \
    "${ASSERTION}" \
    "[ \${STATUS} != 0 ]" \
    "\"${MESSAGE}\""
}

assert_status_code() {
  local EXPECTED_STATUS=$1
  local ASSERTION="$2"
  local MESSAGE="${3:-}"

  _assert_expression \
    "${ASSERTION}" \
    "[ \${STATUS} == ${EXPECTED_STATUS} ]" \
    "expected status code [${EXPECTED_STATUS}] but was ${STATUS}"
}

assert_contains() {
  local EXPECTED=$1
  local ACTUAL=$2
  
  if [[ ! " ${ACTUAL[*]} " =~ " ${EXPECTED} " ]]
  then
    echo -n "FAILURE"
    echo -e "\n\t\texpected [${EXPECTED}] in stack but stack contains [${ACTUAL}]"
    return 1
  fi
}

assert_string_contains() {
  local EXPECTED=$1
  local ACTUAL=$2

  if [[ ! ${ACTUAL} == *"${EXPECTED}"* ]]
  then
    echo -n "FAILURE"
    echo -e "\n\t\texpected [${EXPECTED}] in string but string contains [${ACTUAL}]"
    return 1
  fi
}

tstfy_run_test() {
  set -e
  "${1}"
}

tstfy() {
  declare -a TESTS

  if [[ -d $@ ]]
  then
    TEST_FILES=$(find tests -type f -name "test-*")
  else
    TEST_FILES=$@
  fi

  TEST_COUNTER=0
  TEST_COUNTER_FILES=0
  TEST_COUNTER_SUCCESS=0
  TEST_COUNTER_FAILED=0

  for TEST_FILE in ${TEST_FILES[@]}
  do
    FILE_EXISTS=TRUE
    FILE_READABLE=TRUE

    test -e "${TEST_FILE}" || FILE_EXISTS=FALSE
    test -r "${TEST_FILE}" || FILE_READABLE=FALSE

    if [[ ${FILE_EXISTS} == FALSE ]]
    then
      echo -e "File ${TEST_FILE} does not exist. Skipping."
    fi

    if [[ ${FILE_READABLE} == FALSE ]]
    then
      echo -e "File ${TEST_FILE} is not readable. Skipping."
    fi

    if [[ ${FILE_EXISTS} == TRUE ]] &&
       [[ ${FILE_READABLE} == TRUE ]]
    then
      TEST_COUNTER_FILES=$[$TEST_COUNTER_FILES +1]
      echo ""
      echo "Running tests in ${TEST_FILE}"
      source ${TEST_FILE}

      for TEST in $(set | "${GREP}"  -E '^test.* \(\)' | "${SED}" -e 's: .*::')
      do
        if [[ ! " ${TESTS[@]} " =~ " ${TEST} " ]]; then
          TESTS=("${TESTS[@]}" ${TEST})
          TEST_COUNTER=$[$TEST_COUNTER +1]

          # run test
          echo -en "\tRunning ${TEST} ... "

          local STATUS=0
          declare -F | "${GREP}" ' setup$' >/dev/null && setup
          tstfy_run_test ${TEST} || STATUS=$?
          declare -F | "${GREP}" ' teardown$' >/dev/null && teardown

          # check status
          if [[ ${STATUS} == 0 ]]
          then
            echo -n "ok"
            TEST_COUNTER_SUCCESS=$[$TEST_COUNTER_SUCCESS +1]
          else
            TEST_COUNTER_FAILED=$[$TEST_COUNTER_FAILED +1]
            TEST_STATUS=FALSE
          fi
      
          echo -e " "
        fi
      done
    fi
  done
  echo -e "${TEST_COUNTER} test(s) in ${TEST_COUNTER_FILES} file(s), ${TEST_COUNTER_SUCCESS} succeed, ${TEST_COUNTER_FAILED} failed\n"
}
tstfy $@

if [[ ${TEST_STATUS} == FALSE ]]
then
  exit 1
fi