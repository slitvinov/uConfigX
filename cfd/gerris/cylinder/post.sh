#!/bin/bash

for d in Refine_*; do
    (
	cd $d
	find . -name  '*.vtk' | awk '{o=$1; sub("./profile.", ""); sub(".vtk", ""); print $0, o}' | sort -g | awk '{print $2}' > v.visit
    )
done




