#!/usr/bin/awk -f
# (xc, yc, zc) to matrix

function cell0(xc, yc, zc, phix) {
    printf "0.000000 0.000000 0.000000\n"
    printf "1.000000 0.000000 0.000000 %g\n", xc
    printf "0.000000 %g %g %g\n",  cos(phix), -sin(phix), yc
    printf "0.000000 %g %g %g\n",  sin(phix),  cos(phix), -zc
    printf "0.000000 0.000000 0.000000 1.000000\n"
}

BEGIN {
    phix = length(phix) ? phix : 0.0
}
    

{
    xc = $1; yc = $2; zc = $3
    cell0(xc, yc, zc, phix)
}

