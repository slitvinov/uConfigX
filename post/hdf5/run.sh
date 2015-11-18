#!/bin/bash

set -e

wrk=~/tmp/stochastic_seed_many
mkdir -p $wrk

d=$1

mkdir -p $wrk/$d
(
    cd $d/uConfigX/uDeviceX/mpi-dpd/h5/
    ur av_and_reduce.sh $wrk/$d/av.h5 `ls -1 flowfields-*.h5 | awk 'NR>10'`
)
