#!/bin/bash

. local/panda/vars.sh

set -xue

safe_ln() {
    test -h "$2" || ln -s "$1" "$2"
}

# create symbolic links
(
    cd ../
    safe_ln uConfigX/uDeviceX/mpi-dpd/ply ply
    safe_ln uConfigX/uDeviceX/mpi-dpd/h5  h5
    safe_ln uConfigX/uDeviceX/mpi-dpd/diag.txt  diag.txt
)

orgNv=498
if test $Nv -ne $orgNv
then
    # generate cell template
    local/panda/gen$Nv.sh  | ur scaleudevice.awk -v sc=1 > uDeviceX/cuda-rbc/rbc.dat
else
    ur scaleudevice.awk -v sc=1.00 pre/cell-template/rbc.org.dat > uDeviceX/cuda-rbc/rbc.dat
fi

pi_over2=1.570796326794897
box="-v Lx=$Lx -v Ly=$Ly -v Lz=$Lz"

# place one RBC
#awk $box 'BEGIN {print Lx/10, Ly/2, Lz/2}' | \
#awk $box 'BEGIN {print Lx/2, 0.80*Ly, Lz/2}' | \
#    ur cell-placement0.awk -v phix=0 > uDeviceX/mpi-dpd/rbcs-ic.txt

# place multiple RBCs
awk $box 'BEGIN {print 0.25*Lx, 0.75*Ly, Lz/2; print 0.25*Lx, 0.85*Ly, Lz/2; print 0.25*Lx, 0.950*Ly, Lz/2
                 print 0.75*Lx, 0.75*Ly, Lz/2; print 0.75*Lx, 0.85*Ly, Lz/2; print 0.75*Lx, 0.950*Ly, Lz/2 }' | \
    ur cell-placement0.awk -v phix=$pi_over2 > uDeviceX/mpi-dpd/rbcs-ic.txt

# place A LOT of RBCs - fill the space!
#awk $box -v A=$totArea0 -v reff=$reff -v rf=$rf -f pre/cell-distribution/cell-placement-hcp.awk | \
#    awk -f pre/cell-distribution/cell-placement0.awk > uDeviceX/mpi-dpd/rbcs-ic.txt

case $geom in
    cir) # cylinder in rectangle
	ur tsdf.awk pre/tsdf/examples/cylinder_in_rect.tsdf uDeviceX/mpi-dpd/sdf.dat uDeviceX/mpi-dpd/sdf.vti
	;;
    eir) # egg in rectangle
	ur tsdf.awk pre/tsdf/examples/egg_in_rect.tsdf      uDeviceX/mpi-dpd/sdf.dat uDeviceX/mpi-dpd/sdf.vti
	;;
    *)
	ghome=$SCRATCH/geoms/pachinko/post
	cp  $ghome/sdf.dat $ghome/sdf.bov $ghome/sdf.values uDeviceX/mpi-dpd/
esac



