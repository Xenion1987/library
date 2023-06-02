#!/usr/bin/env bash
###########################################
# VERSION 1.0.2
###########################################

function cdebug() {
  #############################################
  # To use this function, you have to call every function as an OPTION for
  # this 'cdebug' function.
  #
  # 1. Write your script and outsource as many steps as possible into your own small functions
  # 2. Write a main function (e.g. named 'main') and execute each function prefixed by 'cdebug'
  # 3. Export 'DEBUG_ENABLED=true' and start the script to debug every function in 'main'
  #
  # EXAMPLE SCRIPT:
  ######
  # function foo() {
  #   echo "bar"
  # }
  # function main() {
  #   cdebug foo
  # }
  # main
  ######
  #
  # EXAMPLE USAGE:
  #
  #   export DEBUG_ENABLED=true &&  /bin/bash SCRIPTNAME
  #############################################

  #############################################
  # Resolving dependencies
  #############################################
  local FUNC_DEPENDENCIES
  local LIBRARY_PATH
  local DEPENDENCY
  FUNC_DEPENDENCIES+=(ccolors)
  if [[ ${#FUNC_DEPENDENCIES[@]} -gt 0 ]]; then
    if [[ -z "${LIBRARY_PATH}" ]]; then
      LIBRARY_PATH=$(
        cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
        pwd -P
      )
    fi
    # shellcheck source=/dev/null
    for DEPENDENCY in "${FUNC_DEPENDENCIES[@]}"; do
      if [[ -f "${LIBRARY_PATH}/${DEPENDENCY}.sh" ]]; then
        source "${LIBRARY_PATH}/${DEPENDENCY}.sh"
      else
        echo -n "${FUNCNAME[0]} :: "
        echo "Could not load dependency '${DEPENDENCY}'"
      fi
    done
  fi
  #############################################

  if [[ "${DEBUG_ENABLED}" == "true" ]]; then
    echo -ne "${C_RED}"
    echo "Next function:"
    echo -ne "${C_CYAN}"
    sed -rn "/^function ${1}/,/^\}$/p" "${0}"
    echo -ne "${C_RED}"
    echo "Continue starting function '${1}'? "
    echo -ne "${C_RESET}"
    read -r -n 1 -p "[y/N] " yn
    case "${yn}" in
    y | Y | j | J)
      set -x
      "${@}"
      set +x
      echo -ne "${C_GREEN}"
      echo "Function '${1}' finished."
      echo -ne "${C_RESET}"
      ;;
    *)
      echo "Cancelled by user - EXIT"
      unset DEBUG_ENABLED
      exit 1
      ;;
    esac
  else
    "${@}"
  fi
}
