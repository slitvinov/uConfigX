#!/usr/bin/awk -f
#
# Converts alist of coordinates "xc, yc, zc" to a list of 4x4
# transformation matrixes

function cell0(xc, yc, zc, phix) {
    printf "%g %g %g\n", xc, yc, zc
    printf "1.000000 0.000000 0.000000 %g\n", xc
    printf "0.000000 %g %g %g\n",  cos(phix), -sin(phix), yc
    printf "0.000000 %g %g %g\n",  sin(phix),  cos(phix), zc
    printf "0.000000 0.000000 0.000000 1.000000\n"
}

BEGIN {
    phix = length(phix) ? phix : 0.0
}
    

{
    xc = $1; yc = $2; zc = $3
    cell0(xc, yc, zc, phix)
}

