#!/usr/bin/env bash

function declare_variables() {
  DEFAULT_HOME=/home
  DEFAULT_SHELL=/bin/bash
}
function check_permissions() {
  if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit 1
  fi
}
function validate_username() {
  local re='^[[:lower:]_][[:lower:][:digit:]_-]{2,15}$'
  ((${#USER_NAME} > 16)) && return 1
  [[ ${USER_NAME} =~ $re ]]
  return
}
function validate_pubkey() {
  ssh-keygen -e -f "${PUB_KEY_TEMP_FILE}" -m RFC4716 >"${PUB_KEY_TEMP_FILE}_2" 2>/dev/null
  ssh-keygen -i -f "${PUB_KEY_TEMP_FILE}_2" -m RFC4716 &>/dev/null
  return
}
function check_missing_shell_parameters() {
  # Show help and exit if no Option is given
  if [[ "${#}" == "0" ]]; then
    echo
    cecho "Missing or wrong option: '$1'" "${C_RED}"
    help
    exit 244
  fi
}
function opt_username() {
  check_missing_shell_parameters "${@}"
  USER_NAME="${1}"
  validate_username || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "Username '${USER_NAME}' seems to be an invalid name format"
  if [[ -z "${USER_HOME}" ]]; then
    USER_HOME="${DEFAULT_HOME}/${USER_NAME}"
  fi
}
function opt_userhome() {
  check_missing_shell_parameters "${@}"
  USER_HOME="${1}"
}
function opt_pubkey_string_interactive() {
  if [[ -z ${USER_NAME} ]]; then
    cecho "Please set option '-u' before '-A'" "${C_RED}"
    exit 1
  fi
  if [[ -n ${USER_PUBKEY} ]]; then
    cecho "Skipping option '-a'. 'USER_PUBKEY' already declared."
  else
    getent passwd "${USER_NAME}" &>/dev/null || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "User '${USER_NAME}' does not exist"
    cecho "Please paste '${USER_NAME}'s' public ssh key to be added to" "${C_YELLOW}"
    cecho "'${USER_HOME}/.ssh/authorized_keys':" "${C_YELLOW}"
    read -r USER_PUBKEY
    PUB_KEY_TEMP_FILE="/tmp/pub_key_validation_file"
    echo "${USER_PUBKEY}" >"${PUB_KEY_TEMP_FILE}"
    validate_pubkey || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "Provided ssh public key seems to have an invalid format"
  fi
}
function opt_pubkey_string_noninteractive() {
  check_missing_shell_parameters "${@}"
  if [[ -z ${USER_NAME} ]]; then
    cecho "Please set option '-u' before '-a'" "${C_RED}"
    exit 1
  fi
  if [[ -n ${USER_PUBKEY} ]]; then
    cecho "Skipping option '-A'. 'USER_PUBKEY' already declared."
  else
    getent passwd "${USER_NAME}" &>/dev/null || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "User '${USER_NAME}' does not exist"
    USER_PUBKEY="${1}"
    PUB_KEY_TEMP_FILE="/tmp/pub_key_validation_file"
    echo "${USER_PUBKEY}" >"${PUB_KEY_TEMP_FILE}"
    validate_pubkey || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "Provided ssh public key seems to have an invalid format"
    rm -f "${PUB_KEY_TEMP_FILE}"
  fi
}
function opt_sudoers_string_interactive() {
  if [[ -z ${USER_NAME} ]]; then
    cecho "Please set option '-u' before '-A'" "${C_RED}"
    exit 1
  fi
  if [[ -n ${SUDOERS_LINE} ]]; then
    cecho "Skipping option '-A'. 'SUDOERS_LINE' already declared:\n${SUDOERS_LINE}"
  else
    getent passwd "${USER_NAME}" &>/dev/null || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "User '${USER_NAME}' does not exist"
    cecho "Please paste '${USER_NAME}'s' sudoers line to be added to" "${C_YELLOW}"
    cecho "'/etc/sudoers.d/${USER_NAME}':" "${C_YELLOW}"
    read -r SUDOERS_LINE
  fi
}
function opt_sudoers_string_noninteractive() {
  check_missing_shell_parameters "${@}"
  if [[ -z ${USER_NAME} ]]; then
    cecho "Please set option '-u' before '-a'" "${C_RED}"
    exit 1
  fi
  if [[ -n ${SUDOERS_LINE} ]]; then
    cecho "Skipping option '-a'. 'SUDOERS_LINE' already declared:\n${SUDOERS_LINE}"
  else
    getent passwd "${USER_NAME}" &>/dev/null || cexit \
      -f "${FUNCNAME[0]}" \
      -e "${?}" \
      -l "CRIT" \
      -m "User '${USER_NAME}' does not exist"
    SUDOERS_LINE="${1}"
  fi
}
function construct_user_add_opts() {
  while [[ ${#} -gt 0 ]]; do
    case $1 in
    --user-name | -u)
      shift
      opt_username "${1}"
      ;;
    --user-home | -H)
      shift
      opt_userhome "${1}"
      ;;
    --add-ssh-public-key | -a)
      if [[ -z ${USER_PUBKEY} ]]; then
        shift
        PUBKEY_ADD="True"
        PUBKEY_ADD_ARG="${1}"
      else
        cecho "Skipping option '-a'. 'USER_PUBKEY' already declared."
      fi
      ;;
    --add-ssh-public-key-interactive | -A)
      if [[ -z ${USER_PUBKEY} ]]; then
        PUBKEY_ADD_INTERACTIVE="True"
      else
        cecho "Skipping option '-A'. 'USER_PUBKEY' already declared."
      fi
      ;;
    # --add-sudoers-privileges | -S)
    #   ADD_SUDOERS_PRIVILEGES="True"
    #   ;;
    *)
      echo
      cecho "Missing or wrong option: '$1'" "${C_RED}"
      help_user_add
      exit 1
      ;;
    esac
    shift
  done
  cbanner Adding a new user
  _user_add_exec
  if [[ "${PUBKEY_ADD}" == "True" ]] && [[ "${PUBKEY_ADD_INTERACTIVE}" == "True" ]]; then
    cecho "You have provided option '-a' and '-A'. Use only one of them.\nTry adding a public ssh key again using subcommand 'pubkey'." "${C_RED}"
    help_pubkey_add
  elif [[ "${PUBKEY_ADD}" == "True" ]]; then
    construct_pubkey_add_opts -u "${USER_NAME}" -a "${PUBKEY_ADD_ARG}"
  elif [[ "${PUBKEY_ADD_INTERACTIVE}" == "True" ]]; then
    construct_pubkey_add_opts -u "${USER_NAME}" -A
  fi
}
function construct_pubkey_add_opts() {
  while [[ ${#} -gt 0 ]]; do
    case $1 in
    --user-name | -u)
      shift
      opt_username "${1}"
      ;;
    --add-ssh-public-key | -a)
      shift
      opt_pubkey_string_noninteractive "${1}"
      ;;
    --add-ssh-public-key-interactive | -A)
      if [[ -z ${USER_PUBKEY} ]]; then
        opt_pubkey_string_interactive
      else
        cecho "Skipping option '-A'. 'USER_PUBKEY' already declared."
      fi
      ;;
    *)
      echo
      cecho "Missing or wrong option: '$1'" "${C_RED}"
      help_pubkey_add
      exit 1
      ;;
    esac
    shift
  done
  _pubkey_add_exec
}
function construct_sudoers_add_opts() {
  while [[ ${#} -gt 0 ]]; do
    case $1 in
    --user-name | -u)
      shift
      opt_username "${1}"
      ;;
    --add-sudoers-line | -a)
      shift
      opt_sudoers_string_noninteractive "${1}"
      ;;
    --add-sudoers-line-interactive | -A)
      opt_sudoers_string_interactive
      ;;
    *)
      echo
      cecho "Missing or wrong option: '$1'" "${C_RED}"
      help_sudoers_add
      exit 1
      ;;
    esac
    shift
  done
  _sudoers_add_exec
}
function _user() {
  shift
  declare -A COMMANDS_1=(
    [main]=help_user
    [add]=_user_add
    # [lock]=_user_lock
    # [remove]=_user_remove
    # [unlock]=_user_unlock
  )
  "${COMMANDS_1[${1:-main}]:-${COMMANDS_1[main]}}" "$@"
}
function _user_add() {
  shift
  if [[ -z "${1}" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    help_user_add
    exit 0
  fi
  construct_user_add_opts "${@}"
}
function _user_add_exec() {
  cecho "Adding user '${USER_NAME}' with home '${USER_HOME}'" "${C_YELLOW}"
  # exit 0
  THIS_ERROR=$(useradd -m -d "${USER_HOME}" -s "${DEFAULT_SHELL}" "${USER_NAME}" 2>&1 >/dev/null) || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "$THIS_ERROR"
  cecho "User '${USER_NAME}' created successfully" "${C_GREEN}"

  install -o "${USER_NAME}" -g "${USER_NAME}" -m 700 -d "${USER_HOME}/.ssh" || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "Could not create '${USER_HOME}/.ssh'"

  touch "${USER_HOME}/.ssh/authorized_keys" || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "Could not create '${USER_HOME}/.ssh/authorized_keys'"
  ssh-keygen -b 4096 -t rsa -C "${USER_NAME}_$(date +%F)" -N '' -f "${USER_HOME}/.ssh/id_rsa" 1>/dev/null || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "Could not create initial ssh key pair"

  chown -R "${USER_NAME}":"${USER_NAME}" "${USER_HOME}" || cexit \
    -f "${FUNCNAME[0]}" \
    -e "${?}" \
    -l "CRIT" \
    -m "Could not change ownership for '${USER_HOME}'"
}
function _pubkey() {
  shift
  declare -A COMMANDS_1=(
    [main]=help_pubkey
    [add]=_pubkey_add
    # [remove]=_pubkey_remove
  )
  "${COMMANDS_1[${1:-main}]:-${COMMANDS_1[main]}}" "$@"
}
function _pubkey_add() {
  shift
  if [[ -z "${1}" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    help_pubkey_add
    exit 0
  fi
  construct_pubkey_add_opts "${@}"
}
function _pubkey_add_exec() {
  if ! grep -q -f "${PUB_KEY_TEMP_FILE}" "${USER_HOME}/.ssh/authorized_keys"; then
    if cat "${PUB_KEY_TEMP_FILE}" >>"${USER_HOME}/.ssh/authorized_keys"; then
      clog "${FUNCNAME[0]}" "SUCCESS" "SSH public key added for user '${USER_NAME}': $(cat ${PUB_KEY_TEMP_FILE})"
    fi
  fi
}
function _sudoers() {
  shift
  declare -A COMMANDS_1=(
    [main]=help_sudoers
    [add]=_sudoers_add
    # [modify]=_sudoers_modify
    # [remove]=_sudoers_remove
  )
  "${COMMANDS_1[${1:-main}]:-${COMMANDS_1[main]}}" "$@"
}
function _sudoers_add() {
  shift
  if [[ -z "${1}" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    help_sudoers_add
    exit 0
  fi
  construct_sudoers_add_opts "${@}"
}
function _sudoers_add_exec() {
  # TODO: Add exec function
  echo
}
function help() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} [SUBCOMMAND[SUBCOMMAND[OPTIONS]]]
 
 SUBCOMMANDS:
  user
    Manage users
  pubkey
    Manage ssh public keys
  sudoers
    Manage sudoers files
 
ENDOFHELP
}
function help_user() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} user [SUBCOMMAND]

 SUBCOMMANDS:
  add
    Add a new linux user
  lock
    Lock a linux user
  remove
    Remove a linux user
  unlock
    Unlock a linux user

ENDOFHELP
}
function help_user_add() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} user add -u <USER_NAME> [-H <USER_HOME>][-a <USER_PUBKEY>|-A]
 
 OPTIONS:
  --help, h
    Show this help text and exit
  --user-name, -u <USER_NAME>
    Name of the user to be created
  --user-home, -H <USER_HOME>
    Absolute path to User's home directory.
    Defaults to '/home/<USERNAME>' if not set.
  --add-ssh-public-key, -a <USER_PUBKEY>
    Add User's ssh public key noninteractive
  --add-ssh-public-key-interactive, -A
    Add User's ssh public key interactive
 
ENDOFHELP
}
function help_pubkey() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} pubkey [SUBCOMMAND]

 SUBCOMMANDS:
  add
    Add a new ssh public key to an existing user
  remove
    Remove an existing ssh public key from an existing user

ENDOFHELP
}
function help_pubkey_add() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} pubkey add -u <USER_NAME> [-a <USER_PUBKEY>|-A]
 
 OPTIONS:
  --help, h
    Show this help text and exit
  --user-name, -u <USER_NAME>
    Name of the user to add the public key for
  --add-ssh-public-key, -a <USER_PUBKEY>
    Add User's ssh public key noninteractive
  --add-ssh-public-key-interactive, -A
    Add User's ssh public key interactive
 
ENDOFHELP
}
function help_sudoers() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} sudoers [SUBCOMMAND]

 SUBCOMMANDS:
  add
    Add a new sudoers file for an existing user
  modify
    Modify an existing sudoers file
  remove
    Remove an existing sudoers file

ENDOFHELP
}
function help_sudoers_add() {
  cat <<ENDOFHELP
 
 USAGE:
  $(type -p bash) ${0} sudoers add -u <USER_NAME> -a
 
 OPTIONS:
  --help, h
    Show this help text and exit
  --user-name, -u <USER_NAME>
    Name of the user to add the public key for
  --add-sudoers-line, a <SUDOERS_STRING>
    Add a sudoers file noninteractive
 
ENDOFHELP
}
#############################################
# Resolving dependencies
#############################################
FUNC_DEPENDENCIES+=(ccolors cecho clog cexit cbanner)
if [[ ${#FUNC_DEPENDENCIES[@]} -gt 0 ]]; then
  if [[ -z "${LIBRARY_PATH}" ]]; then
    LIBRARY_PATH="$(
      cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
      pwd -P
    )/bash"
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

declare -A COMMANDS_0=(
  [main]=help
  [user]=_user
  [pubkey]=_pubkey
  [sudoers]=_sudoers)
declare_variables
"${COMMANDS_0[${1:-main}]:-${COMMANDS_0[main]}}" "$@"
