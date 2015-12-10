#!/bin/bash

. ../../../utils/ucx/env.sh

set -eux

e () { awk -v OFMT=%.12g '
function round(x,   ival, aval, fraction)
{
   ival = int(x)    # integer part, int() truncates

   # see if fractional part
   if (ival == x)   # no fraction
      return ival   # ensure no decimals

   if (x < 0) {
      aval = -x     # absolute value
      ival = int(aval)
      fraction = aval - ival
      if (fraction >= .5)
         return int(x) - 1   # -2.5 --> -3
      else
         return int(x)       # -2.3 --> -2
   } else {
      fraction = x - ival
      if (fraction >= .5)
         return ival + 1
      else
         return ival
   }
}
BEGIN {print '"$@"'}'
}       

add_wall_margin () {
    exl=$xl
    eyl=$yl
    ezl=$zl
    
    exh=$xh
    eyh=`e $yh+2*$m`
    ezh=`e $zh+2*$m`

    rxl=`e $rom*$exl`
    ryl=`e $rom*$eyl`
    rzl=`e $rom*$ezl`
    
    rxh=`e $rom*$exh`
    ryh=`e $rom*$eyh`
    rzh=`e $rom*$ezh`
}

nbox () {
    nrs=$1
    printf "%d %d %d\n" `e "round($exh*$nrs)"` `e "round($eyh*$nrs)"` `e "round($ezh*$nrs)"`
}

gen_gts () {
    Lx=`e "($xh)-($xl)"`
    stl2gts < "$1" | \
    transform --rz=90        | \
    transform --tx=$Lx        | \
    transform --ty=$m --tz=$m | \
    transform --scale=$rom      > "$2"
    
    transform --scale=$om < "$2" | gts2stl > sdf.trans.stl # debug output
}

m=2   # wall margin
om=3  # object margin

stl=$1 # input file
gf=5/4

xl=0
yl=0
zl=0

xh=2240
yh=516
zh=52

rom=`e "1/($om)"`
add_wall_margin
gen_gts $stl k.gts

grid_box=`nbox $gf`
box_lo="$rxl $ryl $rzl"
box_hi="$rxh $ryh $rzh"
ur gts2bov.sh k.gts wall.bov $box_lo $box_hi $grid_box

ur transformbov.awk    wall.bov    sdf.bov     $om
ur bov2sdf.awk      -v br=1    sdf.bov     sdf.dat
