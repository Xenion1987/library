#!/usr/bin/env bash
###########################################
# VERSION 1.0.3
###########################################

function cbanner() {
  #############################################
  # DESCRIPTION:
  # Print a banner as an eye catcher or separator
  #
  # EXAMPLE USAGE:
  # cbanner Hello World
  #
  # OUTPUT:
  ########################################
  #             Hello World              #
  ########################################
  #############################################

  #############################################
  # Resolving dependencies
  #############################################
  FUNC_DEPENDENCIES+=()
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
  local STRING="$*"
  local BANNER_SYMBOL="#"
  local BANNER_WIDTH=40
  local BANNER_LINE

  if ((${#STRING} > BANNER_WIDTH - 4)); then
    local WRAPPED_LINES=()
    local LONGEST_LINE_LENGTH=0

    while IFS= read -r LINE; do
      WRAPPED_LINES+=("$LINE")
      if ((${#LINE} > LONGEST_LINE_LENGTH)); then
        LONGEST_LINE_LENGTH=${#LINE}
      fi
    done < <(printf "%s\n" "${STRING}" | fmt -w $((BANNER_WIDTH - 4)))

    BANNER_WIDTH=$((LONGEST_LINE_LENGTH + 6))
    BANNER_LINE=$(printf "%${BANNER_WIDTH}s" | tr ' ' "${BANNER_SYMBOL}")
    echo "${BANNER_LINE}"

    for LINE in "${WRAPPED_LINES[@]}"; do
      printf "#  %-*s  #\n" $((BANNER_WIDTH - 6)) "$LINE"
    done

    echo "${BANNER_LINE}"
  else
    local SPACES_LEFT_COUNT=$(((BANNER_WIDTH - ${#STRING} - 2) / 2))
    BANNER_LINE=$(printf "%${BANNER_WIDTH}s" | tr ' ' "${BANNER_SYMBOL}")
    echo "${BANNER_LINE}"
    echo "#$(printf "%${SPACES_LEFT_COUNT}s")${STRING}$(printf "%$((BANNER_WIDTH - ${#STRING} - 2 - SPACES_LEFT_COUNT))s")#"
    echo "${BANNER_LINE}"
  fi
}
