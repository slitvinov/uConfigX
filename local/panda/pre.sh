#!/bin/bash

. local/panda/vars.sh

set -x
set -u

# generate cell template
local/panda/gen$Nv.sh  | ur scaleudevice.awk -v sc=$sc > uDeviceX/cuda-rbc/rbc.dat

# place a lot of RBCs
box="-v Lx=$Lx -v Ly=$Ly -v Lz=$Lz"
ur cell-placement-hcp.awk $box -v A=$totArea0 -v reff=$reff -v sc=$sc | \
    ur cell-placement0.awk > uDeviceX/mpi-dpd/rbcs-ic.txt
