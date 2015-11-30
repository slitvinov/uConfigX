#!/bin/bash

xl=0
yl=0
zl=0

xh=72
yh=48
zh=24

box="-v xl=$xl -v yl=$yl -v zl=$zl    -v xh=$xh -v yh=$yh -v zh=$zh"
gs=3 # grid scale
mrg=3 # margin
Nv=12 # number of vertices

rst="-v gs=$gs -v mrg=$mrg -v Nv=$Nv"

ply=$HOME/SYNC/wall/reff_2_sc_0.7_kb_2000_ka_2500_kv_3500_mu0_40_ha_100_Nv_362_cshape_0_phirbc_8.20303/ply/rbcs-0599.ply

./ply2sdf.awk $box $rst $ply sdf.dat
