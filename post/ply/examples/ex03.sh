#!/bin/bash

make
Nv=1442
./ply2ascii < examples/rbcs-0000.ply > examples/rbcs.txt.ply
awk -v Nv=$Nv -f scripts/plysplit.awk examples/rbcs.txt.ply

awk -v xl=0 -v xh=24    -v yl=0 -v yh=120     -v zl=0 -v zh=24  -v c=0.25 \
    -f scripts/ply2overlap.awk f.00000[012].ply > overlap.vtk
