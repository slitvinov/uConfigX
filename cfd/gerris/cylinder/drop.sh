#!/bin/bash

Fabs=1e-3
R=9.75
Refine=2

st=0.025
ed=1

d=Refine_${Refine}_st_${st}_ed_${ed}

echo "dirname: $d"

mkdir -p $d

./gboxes.awk  -v ed=$ed -v st=$st -v R=$R -v Fabs=$Fabs -v pshift=inf -v Refine=$Refine -v d2=1 drop.templ.gfs  > $d/s.gfs
(cd $d
 gerris2D s.gfs)
 
