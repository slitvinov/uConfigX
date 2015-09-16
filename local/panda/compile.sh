#!/bin/bash

. local/panda/vars.sh

cp local/panda/Makefile uDeviceX/mpi-dpd/.cache.Makefile
cp local/panda/Makefile uDeviceX/cuda-ctc/.cache.Makefile
cd uDeviceX/mpi-dpd
make -j clean && make slevel="-2"

