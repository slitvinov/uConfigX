#!/bin/bash

# Combine periodic images of Pachinko files
#
# Refs.
# [1] GTS - The GNU Triangulated Surface Library
# Note:
# transform, gts2stl are commands from GTS

set -eu

# GTS [1] source code
GTS_SRC=/home/lisergey/src/pkgsrc/wip/gts-snapshot/work/gts-snapshot-121130
make -C $GTS_SRC/examples

test -f merge   || ln -s $GTS_SRC/examples/merge merge
test -f cleanup || ln -s $GTS_SRC/examples/merge cleanup

eps=1e-5
Ly=2240 # size in y-direction

clean_up () {
    rm -rf ${t?t si empty}
}

t=`mktemp -d`
trap  'clean_up; exit 1' 1 2 5

transform  --ty=$Ly   < pachinko/org_no_btm.gts  > $t/org1.gts
transform  --ty=-$Ly  < pachinko/org_no_top.gts  > $t/org2.gts
transform  --ty=0     < pachinko/org_no_both.gts > $t/org3.gts

./merge $t/org[123].gts                    > combined.gts
gts2stl                   < combined.gts   > combined.stl

printf "(pcombine.sh) created %s and %s\n" combined.gts combined.stl

clean_up
