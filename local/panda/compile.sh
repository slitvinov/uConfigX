#!/bin/bash

. local/panda/vars.sh

cp local/panda/Makefile uDeviceX/mpi-dpd/.cache.Makefile
cp local/panda/Makefile uDeviceX/cuda-ctc/.cache.Makefile
cp local/panda/Makefile uDeviceX/cuda-dpd/.cache.Makefile

cd uDeviceX/mpi-dpd
make clean && make -j slevel="-2"

