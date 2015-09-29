#!/bin/bash

. local/panda/vars.sh

# create cylinder geometry
ur tsdf.awk pre/tsdf-configs/cylinder1.tsdf uDeviceX/mpi-dpd/sdf.dat

# copy rbc template
# cp pre/cell-template/rbc.org.dat uDeviceX/cuda-rbc/rbc.dat
cp ~/cycle.dat                       uDeviceX/cuda-rbc/rbc.dat
# cp   ./uDeviceX/cuda-rbc/sphere14.dat  uDeviceX/cuda-rbc/rbc.dat

# generate several RBCs
ur cell-placement1.awk | sort -g | ur cell-placement0.awk -v phix=$phix >  uDeviceX/mpi-dpd/rbcs-ic.txt
