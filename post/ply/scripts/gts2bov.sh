#!/bin/bash

set -eux

GTS_EXE=$HOME/src/gts-cpt/debug/gts-cpt

fi=$1; shift
bov=$1; shift
val=${bov/.bov/.values}

xl=$1; yl=$2; zl=$3
xh=$4; yh=$5; zh=$6
nx=$7; ny=$8; nz=$9

gdb=/usr/local/cuda-7.5/bin/cuda-gdb
host=panda
params="--verbose --begin-x $xl --begin-y $yl --begin-z $zl --end-x $xh --end-y $yh --end-z $zh --size-x $nx --size-y $ny --size-z $nz"

d=`mktemp -d /tmp/gts2sdf.XXXXX`

(
    cd $d
    mkdir -p out
    echo '('gud-gdb '"'$gdb --fullname /ssh:$host:$GTS_EXE -ex '\"'start $params '<' $fi'\"")'
    $GTS_EXE $params < "$fi"
)

mv $d/wall.bov    "$bov"
mv $d/wall.values "$val"
#rm -rf ${d}
