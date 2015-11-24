#!/bin/bash


# run all tests
# Usage:
# From <gitroor>
# sh tests/check.sh

. utils/ucx/env.sh

set -e

(
    cd post/ply
    ur atest.awk scripts/*.sh scripts/*.awk README.org
)

(
    cd DOE/alpatchio/
    ur atest.awk *.sh *.awk README.org
)

(
    cd pre/trbc
    ur atest.awk *.sh *.awk README.org
)

(
    cd pre/tsdf
    ur atest.awk *.sh *.awk README.org
)
