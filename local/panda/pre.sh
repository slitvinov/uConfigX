#!/bin/bash

. local/panda/vars.sh

set -x
set -u

ur array.awk -v lx=$Lx -v nx=$Nx -v ny=$Ny -v Rx=$Rx -v Ry=$Ry > pre/tsdf-configs/cylinder_top.tsdf
ur tsdf.awk pre/tsdf-configs/cylinder_top.tsdf uDeviceX/mpi-dpd/sdf.dat  uDeviceX/mpi-dpd/sdf.vti
#cp pre/geoms/two_legs1/two.dat uDeviceX/mpi-dpd/sdf.dat

# generate cell template
local/panda/gen$Nv.sh  > uDeviceX/cuda-rbc/rbc.dat
#cp pre/cell-template/rbc.org.dat uDeviceX/cuda-rbc/rbc.dat

# place one RBC
pre/cell-distribution/rbc1-ic.awk -v Lx=$Lx  > uDeviceX/mpi-dpd/rbcs-ic.txt
