#!/bin/bash

# Combine periodic images of Pachinko files
#
# Refs.
# [1] GTS - The GNU Triangulated Surface Library
# Note:
# transform, gts2stl are commands from GTS

set -eu

eps=1e-5 # constant ./cleanup
xl=0
yl=0
zl=0

xh=2240
yh=520
zh=56

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

# GTS [1] source code
GTS_SRC=$HOME/src/pkgsrc/wip/gts-snapshot/work/gts-snapshot-121130
make -C $GTS_SRC/examples

test -f merge   || ln -s $GTS_SRC/examples/merge merge
test -f cleanup || ln -s $GTS_SRC/examples/cleanup cleanup

clean_up () {
    rm -rf ${t?t si empty}
}

t=`mktemp -d`
trap  'clean_up; exit 1' 1 2 5

combine () {
    # `Lx' is for rotated file, for original it is y-direction
    transform  --ty=$Lx   < pachinko/org_no_btm.gts  > $t/org1.gts
    transform  --ty=-$Lx  < pachinko/org_no_top.gts  > $t/org2.gts
    transform  --ty=0     < pachinko/org_no_both.gts > $t/org3.gts

    ./merge $t/org[123].gts | ./cleanup $eps              > "$1"

    printf "(pcombine.sh) created %s\n" "$1"
}

init () {
    Lx=`e $xh-$xl`; Ly=`e $yh-$yl`; Lz=`e $zh-$zl`
    
    exl=$xl; eyl=$yl; ezl=$zl
    exh=$xh; eyh=`e $yh+2*$m`; ezh=`e $zh+2*$m`
    eLx=`e $exh-$exl`; eLy=`e $eyh-$eyl`; eLz=`e $ezh-$ezl`
}

nbox () {
    nrs=$1
    printf "%d %d %d\n" `e "round($exh*$nrs)"` `e "round($eyh*$nrs)"` `e "round($ezh*$nrs)"`
}

gen_gts () {
     cat "$1"                  | \
     transform --rz=90         | \
     transform --tx=$Lx        | \
     transform --ty=$m --tz=$m > \
     "$2"
     printf "(pcombine.sh) created %s\n" "$2"
}

scale_to_gerris() {
    gscx=`e $gLx/$eLx`
    gscy=`e $gLy/$eLy`
    gscz=`e $gLz/$eLz`
    
    cat "$1"                                   | \
    transform --sx=$gscx --sy=$gscy --sz=$gscz    > \
     "$2"
}

m=2   # wall margin

init
combine combined.gts
gen_gts combined.gts    sdf.gts

gLx=560 # `Lx' in gerris
gLy=129
gLz=14

scale_to_gerris sdf.gts          gerris.gts
gts2stl < gerris.gts > gerris.stl

cp gerris.gts $HOME/uConfigX/master/cfd/gerris/proof-of-concept/
cp gerris.stl $HOME/uConfigX/master/cfd/gerris/proof-of-concept/

clean_up
