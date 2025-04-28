#!/bin/bash

if [[ -z "$UTILITIES_SH_SOURCED" ]]; then
    export UTILITIES_SH_SOURCED=true

    # Colors
    export BOLD="\033[1m"
    export UNDER="\033[4m"
    export RED="\033[31m"
    export GREEN="\033[32m"
    export YELLOW="\033[33m"
    export BLUE="\033[34m"
    export MAGENTA="\033[35m"
    export CYAN="\033[36m"
    export RESET="\033[0m"

    # Utility Functions
    error() {
        local message="$1"
        local should_exit="${2:-1}"  # Default is 1 (exit), unless specified

        echo -e "${RED}❌ Error: $message${RESET}" >&2

        if [[ "$should_exit" -eq 1 ]]; then
            exit 1
        fi
    }

    warning() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
    success() { echo -e "${GREEN}✅ $1${RESET}"; }
    info() { echo -e "${CYAN}⚙️  $1${RESET}"; }
    prompt() { echo -e "${MAGENTA}❓ $1${RESET}"; }
    newLine() { info "+---------------------------------------------------------+"; }

    update_property() {
        local file=$1
        local key=$2
        local value=$3
        if grep -q "^$key=" "$file"; then
            sed -i "s|^$key=.*|$key=$value|" "$file"
        else
            echo -e "\n# Created by AmtCode\n$key=$value" >> "$file"
        fi
    }
fi