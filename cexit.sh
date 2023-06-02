#!/usr/bin/env bash
###########################################
# VERSION 1.0.1
###########################################

function cexit() {
  #############################################
  # EXAMPLE USAGE:
  #
  #   yourCommandHere || cexit \
  #    -f "FUNCTION_NAME" \
  #    -e "EXIT_CODE" \
  #    -l "EXIT_LEVEL" \
  #    -m "EXIT_MESSAGE"
  #
  #   yourCommandHere || cexit -f "${FUNCNAME[0]}" -e "${?}" -l "CRIT" -m "Your message here"
  #############################################
  # EXIT_LEVEL should be one of the following:
  #   CRIT
  #   WARN
  #   INFO
  #   SUCCESS
  #   DEBUG
  #############################################
  # Custom exit codes:
  #############################################
  #   255: Unknown error
  #   244: Missing or wrong option
  #############################################

  #############################################
  # Resolving dependencies
  #############################################
  FUNC_DEPENDENCIES+=(clog)
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

  while (($#)); do
    case "${1}" in
    --exit | -e)
      shift
      EXIT_CODE=${1:-"255"}
      ;;
    --function | -f)
      shift
      FUNCTION_NAME=${1:-"UNKNOWN_FUNCTION"}
      ;;
    --level | -l)
      shift
      EXIT_LEVEL=${1:-"UNKNOWN_EXIT_LEVEL"}
      ;;
    --message | -m)
      shift
      EXIT_MESSAGE="${1}"
      EXIT_CODE_AND_MESSAGE="EXIT CODE ${EXIT_CODE} :: ${EXIT_MESSAGE}"
      clog "${FUNCTION_NAME}" "${EXIT_LEVEL}" "${EXIT_CODE_AND_MESSAGE}"
      ;;
    esac
    shift
  done
  unset DEBUG_ENABLED
  exit "${EXIT_CODE}"
}
