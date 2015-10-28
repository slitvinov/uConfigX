#!/bin/bash

. local/panda/vars.sh

set -x
set -u

pre/tsdf-configs/cylinder.awk -v Lx=$Lx  > pre/tsdf-configs/cylinder.gen.tsdf
ur tsdf.awk pre/tsdf-configs/cylinder.gen.tsdf uDeviceX/mpi-dpd/sdf.dat  uDeviceX/mpi-dpd/sdf.vti

# create a sphere template
# 12
# 42
# 92
# 162
# 362
# 812
1442

# generate cell template
local/panda/gen$Nv.sh  > uDeviceX/cuda-rbc/rbc.dat
#cp pre/cell-template/rbc$Nv.dat uDeviceX/cuda-rbc/rbc.dat

# place one RBC
pre/cell-distribution/rbc1-ic.awk -v Lx=$Lx  > uDeviceX/mpi-dpd/rbcs-ic.txt
