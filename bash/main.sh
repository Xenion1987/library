#!/usr/bin/env bash
###########################################
# VERSION 1.0.1
###########################################

#############################################
# This is an example function to demonstrate how to use a 'main' function
# and loop though different options.
#############################################

#############################################
# Resolving dependencies
#############################################
local FUNC_DEPENDENCIES
local LIBRARY_PATH
local DEPENDENCY
FUNC_DEPENDENCIES+=(debug_single_function)
FUNC_DEPENDENCIES+=(ccolors chelp cecho)

if [[ ${#FUNC_DEPENDENCIES[@]} -gt 0 ]]; then
  LIBRARY_PATH=$(
    cd -- "$(dirname "${0}")" >/dev/null 2>&1 || exit
    pwd -P
  )
  # shellcheck source=/dev/null
  for DEPENDENCY in "${FUNC_DEPENDENCIES[@]}"; do
    if [[ -f "${LIBRARY_PATH}/${DEPENDENCY}.sh" ]]; then
      source "${LIBRARY_PATH}/${DEPENDENCY}.sh"
    else
      echo "Could not load dependency '${DEPENDENCY}'"
    fi
  done
fi
#############################################
function main() {
  # Show help and exit if no Option is given
  if [[ "${#}" == "0" ]]; then
    echo
    cecho "Missing or wrong option" "${C_RED}"
    chelp
    exit 244
  fi

  # Check for commands that should be executed as single option only
  case "${1}" in
  --debug)
    shift
    if [[ -z $1 ]]; then
      cecho "Missing or wrong option" "${C_RED}"
      exit 244
    else
      debug_single_function "${@}"
      exit 0
    fi
    ;;
  --help | -h)
    chelp
    exit 0
    ;;
  esac

  # If no single option found, loop through each option instead
  while (("${#}")); do
    case ${1} in
    --say | -s)
      shift
      if [[ -z $1 ]]; then
        cecho "Missing or wrong option" "${C_RED}"
        exit 244
      else
        echo "Your message:"
        echo "${1}"
      fi
      ;;
    *)
      echo
      cecho "Missing or wrong option" "${C_RED}"
      chelp
      exit 244
      ;;
    esac
    shift
  done
}
