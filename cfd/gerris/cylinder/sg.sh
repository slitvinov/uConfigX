#!/bin/bash

Fabs=0.16
Refine=1

st=60.0
Rd=2.2
yd=30

d=Refine_${Refine}_st_${st}_Fabs_${Fabs}_yd_${yd}

echo "dirname: $d"

mkdir -p $d

./gboxes.awk  -v yd=$yd -v Rd=$Rd -v st=$st \
	      -v Fabs=$Fabs -v pshift=inf -v Refine=$Refine -v d2=1 sg.templ.gfs  > $d/s.gfs
(cd $d
 gerris2D s.gfs)
