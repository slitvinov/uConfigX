#!/bin/bash

. local/panda/vars.sh

set -x
set -u

ur array.awk -v lx=$lx -v nx=$Nx -v ny=$Ny -v R=$R > pre/tsdf-configs/cylinder_top.tsdf
ur tsdf.awk pre/tsdf-configs/cylinder_top.tsdf uDeviceX/mpi-dpd/sdf.dat  uDeviceX/mpi-dpd/sdf.vti

# create a sphere template
# 12
# 42
# 92
# 162
# 362
# 812
# 1442

local/panda/gen$Nv.sh  > uDeviceX/cuda-rbc/rbc.dat
#cp pre/cell-template/rbc.org.dat     uDeviceX/cuda-rbc/rbc.dat

# generate several RBCs
ur cell-placement1.awk -v ly=$lx -v Lx=$XSIZE_SUBDOMAIN | \
    sort -g | ur cell-placement0.awk -v phix=$phix > uDeviceX/mpi-dpd/rbcs-ic.txt
