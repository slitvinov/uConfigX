#!/bin/bash

Nv=1442
./ply2ascii < examples/rbcs-0000.ply > examples/rbcs.txt.ply
awk -v Nv=$Nv -f scripts/plysplit.awk examples/rbcs.txt.ply
