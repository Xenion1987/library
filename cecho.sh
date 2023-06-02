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
  FUNC_DEPENDENCIES+=(ccolors)
  if [[ ${#FUNC_DEPENDENCIES[@]} -gt 0 ]]; then
    LIBRARY_PATH=$(
      cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
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

  DEFAULT_MESSAGE="NO MESSAGE PROVIDED"
  MESSAGE=${1:-${DEFAULT_MESSAGE}}
  COLOR=${2:-${C_RESET}}

  echo -e "${COLOR}${MESSAGE}${C_RESET}"
}
