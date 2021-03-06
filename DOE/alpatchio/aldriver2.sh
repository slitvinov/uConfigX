#!/bin/bash

#set -eu

# Usage:
#  ./aldriver2.sh <source directory> <parameter_line>
. utils/ucx/env.sh

source_directory=$1
parameter_line=$2

tmp_source_directory=`mktemp -d /tmp/alldriver.XXXX`
alpachio_config=`mktemp /tmp/alpachio.XXXX`
cart_list=`mktemp /tmp/cartlist.XXXX`

function msg() {
    printf "(aldriver2.sh) %s\n" "$@"
}

function err() {
    msg "$@"
    exit 2
}

test -d "$source_directory" || \
    err "\"$source_directory\" is not a directory"

function run_case() {
    (
	cd "$tmp_source_directory"
	sh $DEPLOY_CMD
    )
}

function create_case() {
    msg "create_case: $source_directory $tmp_source_directory"
    test -d "$tmp_source_directory" && rm -rf "$tmp_source_directory"
    cp -r "$source_directory" "$tmp_source_directory"

    msg "config file: $alpachio_config"
    ur allineario.awk "$1" > "$alpachio_config"

    ur alpachio.sh "$alpachio_config" \
       `ur appendf.awk -v prefix="${tmp_source_directory}/" "$SUBST_FILE"`
    run_case
}

create_case "$parameter_line"
