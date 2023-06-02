#!/usr/bin/env bash
###########################################
# VERSION 1.0.2
###########################################

function clog() {
  #############################################
  # EXAMPLE USAGE:
  #
  #   clog "FUNCNAME" "LOG_LEVEL" "MESSAGE"
  #   clog "${FUNCNAME[0]}" "INFO" "Your message here"
  #############################################
  # LOG_LEVEL should be one of the following:
  #   CRIT
  #   WARN
  #   INFO
  #   SUCCESS
  #   DEBUG
  #############################################

  #############################################
  # Resolving dependencies
  #############################################
  local FUNC_DEPENDENCIES
  local LIBRARY_PATH
  local DEPENDENCY
  FUNC_DEPENDENCIES+=(ccolors cecho)
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

  LOG_FUNCTION_NAME=${1:-"FUNCTION NAME NOT PROVIDED"}
  LOG_LEVEL=${2:-"LOG LEVEL NOT PROVIDED"}
  LOG_MESSAGE=${3:-"NO MESSAGE PROVIDED"}
  # shellcheck disable=SC2086
  logger -p info -t "$(basename ${0})[${LOG_FUNCTION_NAME}]: $(whoami)[${$}]" "${LOG_LEVEL} :: ${LOG_MESSAGE}"
  case "${LOG_LEVEL}" in
  CRIT | UNKNOWN)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_RED}" >&2
    ;;
  WARN)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_YELLOW}" >&2
    ;;
  INFO)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_RESET}" >&2
    ;;
  SUCCESS)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_GREEN}" >&2
    ;;
  DEBUG)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_CYAN}" >&2
    ;;
  *)
    cecho "$(date '+%F %T') :: ${LOG_FUNCTION_NAME} :: ${LOG_LEVEL} :: ${LOG_MESSAGE}" "${C_RED}" >&2
    ;;
  esac
}
