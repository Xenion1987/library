#!/usr/bin/env bash
###########################################
# VERSION 1.0.3
###########################################

function cecho() {
  #############################################
  # EXAMPLE USAGE:
  #
  #   cecho "MESSAGE" "COLOR"
  #   cecho "Your message here" "${C_GREEN}"
  #############################################

  #############################################
  # Resolving dependencies
  #############################################
  set -x
  local FUNC_DEPENDENCIES
  local LIBRARY_PATH
  local DEPENDENCY
  FUNC_DEPENDENCIES+=(clog)
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

  DEFAULT_MESSAGE="NO MESSAGE PROVIDED"
  MESSAGE=${1:-${DEFAULT_MESSAGE}}
  COLOR=${2:-${C_RESET}}

  echo -e "${COLOR}${MESSAGE}${C_RESET}"
}
