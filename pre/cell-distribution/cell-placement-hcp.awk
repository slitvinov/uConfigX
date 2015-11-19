#!/usr/bin/awk -f
# generate coordiantes of Hexagonal Close Packing of spehres

function abs(x)  { return x<0?x*-1:x}
function asin(x) { return atan2(x, sqrt(abs(1-x*x))) }
function acos(x) { return atan2(sqrt(abs(1-x*x)), x)}
function pi() { return 2*asin(1)}

function indomain(x, y, z) {
    if (x+r>Lx) return 0
    if (x-r<0 ) return 0

    if (y+r>Ly) return 0
    if (y-r<0 ) return 0

    if (z+r>Lz) return 0
    if (z-r<0 ) return 0

    return 1
}

BEGIN {
    r  = sqrt(A)/(2*sqrt(pi()))
    r *= rf
    r *= reff

    nmax = 100
    for (i=0; i<nmax; i++) {
	for (j=0; j<nmax; j++) {
	    for (k=0; k<nmax; k++) {
		x = 2*i + ((j+k) % 2)
		y = sqrt(3) * (j + 1/3*(k % 2))
		z = 2*sqrt(6)/3*k

		x*=r
		y*=r
		z*=r

		if (indomain(x, y, z))
		    print x, y, z
	    }
	}
    }
}
