#!/bin/bash

. local/panda/vars.sh

cp local/daint/Makefile uDeviceX/mpi-dpd/.cache.Makefile
cp local/daint/Makefile uDeviceX/cuda-ctc/.cache.Makefile

(
    . local/daint/load_modules.sh
    cd uDeviceX/mpi-dpd
    make clean && make -j slevel="-2"
)
