#!/bin/bash

. local/panda/vars.sh

set -xue

safe_ln() {
    test -h "$2" || ln -s "$1" "$2"
}

unsafe_ln() {
    test -h "$2" && rm "$2"
    ln -s "$1" "$2"
}

# create symbolic links
(
    cd ../
    safe_ln uConfigX/uDeviceX/mpi-dpd/ply ply
    safe_ln uConfigX/uDeviceX/mpi-dpd/h5  h5
    safe_ln uConfigX/uDeviceX/mpi-dpd/diag.txt  diag.txt

    d=`pwd`
    d=`basename $d`
    (
	cd ..
	unsafe_ln $d                                   c
    )
)

orgNv=498
if test $Nv -ne $orgNv
then
    # generate cell template
    local/panda/gen$Nv.sh  | ur scaleudevice.awk -v sc=1 > uDeviceX/cuda-rbc/rbc.dat
else
    echo "not scale rbc.dat"
    #cp   uDeviceX/cuda-rbc/rbc2.atom_parsed                uDeviceX/cuda-rbc/rbc.dat
    ur scaleudevice.awk -v sc=0.737 pre/cell-template/rbc.org.dat > uDeviceX/cuda-rbc/rbc.dat
fi

pi_over2=1.570796326794897
box="-v Lx=$Lx -v Ly=$Ly -v Lz=$Lz"

# place one RBC
# awk $box 'BEGIN {print Lx/2, 0.75*Ly, Lz/2}' | \
#    ur cell-placement0.awk -v phix=$pi_over2 > uDeviceX/mpi-dpd/rbcs-ic.txt

# place multiple RBCs
#awk $box 'BEGIN {print 0.25*Lx, 0.75*Ly, Lz/2; print 0.25*Lx, 0.85*Ly, Lz/2; print 0.25*Lx, 0.950*Ly, Lz/2
#                 print 0.75*Lx, 0.75*Ly, Lz/2; print 0.75*Lx, 0.85*Ly, Lz/2; print 0.75*Lx, 0.950*Ly, Lz/2 }' | \
#    ur cell-placement0.awk -v phix=$pi_over2 > uDeviceX/mpi-dpd/rbcs-ic.txt

# place A LOT of RBCs - fill the space!
awk $box -v A=$totArea0 -v reff=1 -v sc=1.5 -f pre/cell-distribution/cell-placement-hcp.awk | \
    ur cell-placement0.awk -v phix=$pi_over2 > uDeviceX/mpi-dpd/rbcs-ic.txt

gen_pachinko () {
    (
	cd uDeviceX/cell-placement
	make
	hematocrit=40
	./pachinko $Lx $Ly $Lz     10 10 10   $hematocrit
    )
    cp uDeviceX/cell-placement/rbcs-ic.txt uDeviceX/mpi-dpd/rbcs-ic.txt
}

#gen_pachinko

case $geom in
    cir) # cylinder in rectangle
	ur tsdf.awk pre/tsdf/examples/cylinder_in_rect.tsdf uDeviceX/mpi-dpd/sdf.dat uDeviceX/mpi-dpd/sdf.vti
	;;
    eir) # egg in rectangle
	pre/tsdf/examples/egg_in_rect.awk      $box         >   uDeviceX/mpi-dpd/sdf.tsdf
	ur tsdf.awk uDeviceX/mpi-dpd/sdf.tsdf                   uDeviceX/mpi-dpd/sdf.dat   uDeviceX/mpi-dpd/sdf.vti
	;;
    *)
	ghome=$SCRATCH/geoms/pachinko/post
	cp  $ghome/sdf.dat $ghome/sdf.bov $ghome/sdf.values uDeviceX/mpi-dpd/
esac



