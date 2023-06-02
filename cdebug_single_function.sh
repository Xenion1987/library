#!/usr/bin/env bash
###########################################
# VERSION 1.0.2
###########################################

function debug_single_function() {

  #############################################
  # You have to have defined an OPTION '--debug'
  # to call this function.
  #
  # EXAMPLE OPTION IN 'main' FUNCTION
  ######
  # case "${1}" in
  #   --debug)
  #   shift
  #   debug_single_function "${@}"
  #   ;;
  # esac
  ######
  #
  # EXAMPLE USAGE:
  #
  #   To debug for example the function 'chelp':
  #   /bin/bash SCRIPTNAME --debug chelp
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

  echo -ne "${C_CYAN}"
  echo '###########################################'
  echo '#############    D E B U G    #############'
  echo '###########################################'
  echo -ne "${C_RESET}"
  echo
  FUNCTIONS_LIST=$(sed -nr 's/^function ([0-9a-zA-Z_\-]+)\(\) \{$/\1/p' "${0}" | sort)
  echo -ne "${C_GREEN}"
  echo "Possible functions to call:"
  echo -ne "${C_RESET}"
  echo "${FUNCTIONS_LIST}"
  echo '###########################################'
  echo
  if [[ -n ${1} ]]; then
    set -x
    if ! "${@}"; then
      exit ${?}
    fi
    set +x
  fi

  return
}
