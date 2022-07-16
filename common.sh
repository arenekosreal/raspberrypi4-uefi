#!/usr/bin/env bash

set -e

function is_in_line(){
    # is_in_line /path/to/file $string
    for line in $(cat $1)
    do
        [[ "$2" == "${line}" ]] && return 0
    done
    return 1
}

