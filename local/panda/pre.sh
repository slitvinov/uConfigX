#!/bin/bash

. local/panda/vars.sh

# create cylinder geometry
ur tsdf.awk pre/tsdf-configs/cylinder1.tsdf uDeviceX/mpi-dpd/sdf.dat

# generate several RBCs
ur cell-placement1.awk | sort -g | ur cell-placement0.awk -v phix=$phix >  uDeviceX/mpi-dpd/rbcs-ic.txt
