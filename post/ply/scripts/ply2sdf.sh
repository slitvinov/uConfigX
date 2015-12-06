#!/bin/bash

set -eux

. ../../../utils/ucx/env.sh
make -C ../../../pre/tsdf
make -C ../../../post/ply
make -C ../../../pre/bov

xl=0
yl=0
zl=0

xh=72
yh=48
zh=24

box="-v xl=$xl -v yl=$yl -v zl=$zl    -v xh=$xh -v yh=$yh -v zh=$zh"
gs=6  # grid scale
mrg=3  # margin
Nv=812 # number of vertices

rst="-v gs=$gs -v mrg=$mrg -v Nv=$Nv"
                     
ply=$HOME/SYNC/nwall/reff_1.3_sc_0.7_kb_2000_ka_2500_kv_3500_mu0_40_ha_100_Nv_812_cshape_1_phirbc_5.44292/ply/rbcs-0599.ply
# ply=$HOME/SYNC/nwall/reff_2_sc_0.7_kb_2000_ka_2500_kv_3500_mu0_40_ha_100_Nv_812_cshape_1_phirbc_5.44292/ply/rbcs-0000.ply

cp $ply rbc.ply
./ply2sdf.awk $box $rst $ply sdf.dat

ur sdf2vtk sdf.dat sdf.vti

# TODO:
cp rbc.ply sdf.dat sdf.vti $HOME/uConfigX/slave/pre/geoms/
ur sdf2bov.awk  sdf.dat ~/sdf.bov
