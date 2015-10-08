#!/bin/bash

. local/panda/vars.sh

(
    cd uDeviceX/cuda-dpd
    patch < ../../local/panda/cuda-dpd-Makefile.patch
)

(
    cd uDeviceX/mpi-dpd
    patch < ../../local/panda/mpi-dpd-main.cu.patch
#    patch < ../../local/panda/mpi-dpd-common.h.patch
)

