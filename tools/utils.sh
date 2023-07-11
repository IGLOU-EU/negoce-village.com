#!/bin/bash

readonly SUCCESS=0
readonly FAILURE=1

# set colors variables
if tput colors >/dev/null 2>&1; then
    COLOR_RESET="\e[0m"
    COLOR_SUCCESS="\e[32m"
    COLOR_WARNING="\e[33m"
    COLOR_ERROR="\e[31m"
fi

# error message
error() {
    echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $*" >&2
    return $FAILURE
}

# warning message
warning() {
    echo -e "${COLOR_WARNING}[WARNING]${COLOR_RESET} $*"
    return $SUCCESS
}

# success message
success() {
    echo -e "${COLOR_SUCCESS}[SUCCESS]${COLOR_RESET} $*"
    return $SUCCESS
}

# fatal with error message
fatal() {
    error "$*"
    exit $FAILURE
}

# check if the command list in the argument is installed
check_requirements() {
    local not_found=$SUCCESS

    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Command '$cmd' not found"
            not_found=$FAILURE
        fi
    done

    if [ $not_found -eq $FAILURE ]; then
        fatal "Please install the missing commands and try again"
    fi

    success "All requirements are satisfied"
    return $SUCCESS
}   
