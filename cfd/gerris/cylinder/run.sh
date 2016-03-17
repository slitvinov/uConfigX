#!/bin/bash

Fabs=1.114930530436074e-4
R=9.75
Refine=2

d=sim${Refine}
mkdir -p $d

echo $d

./gp.awk -v d=$d # generate profiles for ouptut
./gboxes.awk  -v R=$R -v Fabs=$Fabs -v pshift=inf -v Refine=$Refine -v d2=1 script.templ.gfs  > $d/s.gfs
(cd $d
 gerris2D s.gfs)
 
