#!/bin/bash

. local/panda/vars.sh

set -x
set -u

#pre/tsdf-configs/ellipse.awk -v Lx=$Lx  > pre/tsdf-configs/ellipse.gen.tsdf
#ur tsdf.awk pre/tsdf-configs/ellipse.gen.tsdf uDeviceX/mpi-dpd/sdf.dat  uDeviceX/mpi-dpd/sdf.vti
ur array.awk -v lx=$Lx -v nx=$Nx -v ny=$Ny -v Rx=$Rx -v Ry=$Ry > pre/tsdf-configs/cylinder_top.tsdf
ur tsdf.awk pre/tsdf-configs/cylinder_top.tsdf uDeviceX/mpi-dpd/sdf.dat  uDeviceX/mpi-dpd/sdf.vti

# generate cell template
local/panda/gen$Nv.sh  > uDeviceX/cuda-rbc/rbc.dat
#cp pre/cell-template/rbc$Nv.dat uDeviceX/cuda-rbc/rbc.dat

# place one RBC
pre/cell-distribution/rbc1-ic.awk -v Lx=$Lx  > uDeviceX/mpi-dpd/rbcs-ic.txt
