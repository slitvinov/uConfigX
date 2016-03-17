#!/bin/bash

i=0
for Refine in 1 2 3; do
for Uabs   in 100.0 10.0 1.0 0.1 0.01; do
for pshift in 1 10 40; do
d=Uabs_${Uabs}_pshift_${pshift}_Refine_${Refine}
mkdir -p $d
./gp.awk -v d=$d
./gboxes.awk  -v Uabs=$Uabs -v pshift=$pshift -v Refine=$Refine -v d2=0 script.templ.gfs  > $d/s.gfs
echo "cd    $d; gerris3D s.gfs" > r${i}.sh
echo "./r${i}.sh"              
i=$(($i+1))
done
done
done
 

