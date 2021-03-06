#!/usr/bin/env bash

NAV_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

: "${CONFIG_LOCATION:=${HOME}}"
CONFIG_PATH="${CONFIG_LOCATION}/.nav/"
if [ ! -d "${CONFIG_PATH}" ]; then
  mkdir -p "${CONFIG_PATH}"
fi

MAP="${CONFIG_PATH}/MAP.txt"
if [ ! -f "${MAP}" ]; then
  touch "${MAP}"
fi

# Formatting config
NO_ACTION_MESSAGES="false"
FORMAT="true"

RED="\033[0;31m"
BLUE="\033[0;34m"
GREY="\033[0;37m"
ORANGE="\033[0;33m"
GREEN="\033[0;32m"
NC="\033[0m"

BOLD=$(tput bold)
NF=$(tput sgr0)

help_pin="Usage: nav pin [location] (alias)"
help_to="Usage: nav to [alias]"
help_rm="Usage: nav rm [alias]"

__nav_message() {
  local type="${1}"
  local message="${2}"

  if [ "${NO_ACTION_MESSAGES}" = "true" ] && [ "${type}" = "action" ]; then
    return 0
  fi

  local colour="${NC}"
  local format="${NF}"

  if [ "${FORMAT}" = "false" ]; then
    echo "${message}"
  else
    case "${type}" in
    error)
      colour="${RED}"
      message="Error: ${message}"
      ;;
    warning)
      colour="${ORANGE}"
      message="Warning: ${message}"
      ;;
    info) colour="${GREY}" ;;
    action) colour="${GREEN}" ;;
    instruction) colour="${BLUE}" ;;
    header) format="${BOLD}" ;;
    table) message=$(echo "${message}" | column -s "=" -t) ;;
    esac

    echo -e "${format}${colour}${message}${NF}${NC}"
  fi
}

__nav_get_usage_instructions() {
  __nav_message header "Available actions:"
  __nav_message generic "- $(__nav_message instruction pin) $(__nav_message info "(${help_pin})")"
  __nav_message generic "- $(__nav_message instruction to) $(__nav_message info "(${help_to})")"
  __nav_message generic "- $(__nav_message instruction rm) $(__nav_message info "(${help_rm})")"
  __nav_message generic "- $(__nav_message instruction list)"
  __nav_message generic "- $(__nav_message instruction which)"
  __nav_message generic "- $(__nav_message instruction which-conf)"
}

__nav_resolve_alias() {
  local location

  while read -r line; do
    # Splitting the decleration and assignment here causes this variable to be printed like so: "alias=something"
    # shellcheck disable=SC2155
    local alias=$(echo "${line}" | cut -d "=" -f 1)

    if [ "${1}" = "${alias}" ]; then
      location=$(echo "${line}" | cut -d "=" -f 2)
      break
    fi
  done <"${MAP}"

  if [ -n "${location}" ]; then
    echo "${location}"
  fi
}

__nav_normalise_location_path() {
  local location="${1}"

  # shellcheck disable=SC2088
  if [ "${location}" = "." ]; then
    location=$(pwd)
  elif [ "${location:0:2}" = "./" ]; then
    location=$(pwd)"${location:1}"
  elif [ "${location}" = ".." ]; then
    # Resolving '..' is not currently supported
    return 1
  elif [ ! "${location:0:1}" = "/" ]; then
    location=$(pwd)"/${location}"
  elif [ "${location}" = "~" ]; then
    location="${HOME}"
  elif [ "${location:0:2}" = "~/" ]; then
    location="${HOME}${location:1}"
  fi

  echo "${location}"
}

__nav_alias_location() {
  if [[ -z "${1}" ]]; then
    __nav_message info "${help_pin}"
    return 1
  fi

  local location_path
  if ! location_path=$(__nav_normalise_location_path "${1}") || [ -z "${location_path}" ]; then
    __nav_message error "'${1}' could not be resolved"
    return 1
  fi

  if [ ! -d "${location_path}" ]; then
    __nav_message error "'${location_path}' is not a directory"
    return 1
  fi

  local alias="${2}"
  if [ -z "${alias}" ]; then
    alias=$(basename "${location_path}")
  elif [[ "${alias}" =~ [^a-zA-Z0-9] ]]; then
    __nav_message error "Alias must only contain alphanumeric characters"
    return 1
  fi

  local existing_alias
  existing_alias=$(__nav_resolve_alias "${alias}")
  if [ -n "${existing_alias}" ]; then
    __nav_message warning "Overwriting existing value for '${alias}'"
    __nav_delete_alias "${alias}"
  fi

  echo "${alias}=${location_path%/}" >>"${MAP}"

  __nav_message action "Pinned ${location_path} as '${alias}'"
}

__nav_goto_location() {
  local alias="${1}"

  if [ -z "${alias}" ]; then
    __nav_message info "${help_to}"
    return 1
  fi

  local location
  location=$(__nav_resolve_alias "${alias}")

  if [ -z "${location}" ]; then
    __nav_message error "No alias found matching '${alias}'"
    return 1
  fi

  cd "${location}" || {
    echo "Could not navigate to ${location}"
    exit 1
  }

  __nav_message action "Moved to ${location}"
}

__nav_delete_alias() {
  local alias="${1}"

  if [ -z "${alias}" ]; then
    __nav_message info "${help_rm}"
    return 1
  fi

  sed -i '' "/^${alias}/d" "${MAP}"

  __nav_message action "Removed location with alias '${alias}'"
}

__nav_list_aliases() {
  local aliases
  aliases=$(cat "${MAP}")

  if [ -n "${aliases}" ]; then
    __nav_message table "${aliases}"
  fi
}

__nav_get_installation_location() {
  __nav_message info "${NAV_PATH}"
}

__nav_get_config_location() {
  __nav_message info "${CONFIG_PATH}"
}

nav() {
  action="${1}"

  case "${action}" in
  pin) __nav_alias_location "${2}" "${3}" ;;
  to) __nav_goto_location "${2}" ;;
  list) __nav_list_aliases ;;
  rm) __nav_delete_alias "${2}" ;;
  help) __nav_get_usage_instructions ;;
  which) __nav_get_installation_location ;;
  which-conf) __nav_get_config_location ;;
  *) nav help ;;
  esac
}
