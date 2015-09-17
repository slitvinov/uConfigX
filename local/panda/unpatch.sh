#!/bin/bash

. local/panda/vars.sh

(
    cd uDeviceX/cuda-dpd
    patch -R < ../../local/panda/cuda-dpd-Makefile.patch
)

(
    cd uDeviceX/mpi-dpd
    patch -R < ../../local/panda/mpi-dpd-main.cu.patch
)
    
