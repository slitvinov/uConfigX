#!/bin/bash

Nv=498
./ply2ascii < examples/rbcs-3067.ply > examples/rbcs.txt.ply
gawk -v Nv=$Nv -f scripts/plysplit.awk examples/rbcs.txt.ply

gawk -v xl=0 -v xh=192    -v yl=0 -v yh=192     -v zl=0 -v zh=96  -v c=1.0 \
    -f scripts/ply2overlap.awk f.*.ply > overlap.vtk
