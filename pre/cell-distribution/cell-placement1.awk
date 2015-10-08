#!/usr/bin/awk -f
# generate a seria of RBC coorrdinates

BEGIN {
    Nc = 3 # number of cells
    yc = ly

    step = Lx/Nc

    for (k=0; k<Nc; k++) {
	xc = 1/2*step + k*step
	zc = xc
	print xc, yc, zc
    }
}
