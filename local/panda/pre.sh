#!/bin/bash

. local/panda/vars.sh

# create cylinder geometry
ur tsdf.awk pre/tsdf-configs/cylinder1.tsdf uDeviceX/mpi-dpd/sdf.dat

# create a sphere template
ur icosahedron.awk  | ur clean.awk | ur unref.awk | ur refine.awk -v r="2 3" | ur unref2vba.awk | ur unref2udevice.awk -v totArea0=$totArea0  > uDeviceX/cuda-rbc/rbc.dat

# generate several RBCs
ur cell-placement1.awk | sort -g | ur cell-placement0.awk -v phix=$phix >  uDeviceX/mpi-dpd/rbcs-ic.txt
