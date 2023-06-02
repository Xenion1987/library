#!/usr/bin/env bash
###########################################
# VERSION 1.0.0
###########################################

function chelp() {
  cat <<ENDOFHELP

 USAGE:
    $(type -p bash) ${0} [OPTIONS]

 OPTIONS:
 --help
    Show this help text and exit
 -h
    Synonym for '--help'
 --debug FUNCTION
    Call a specific single function directly in debug mode.
    If FUNCTION is not given, this option will list all functions.

ENDOFHELP
}
