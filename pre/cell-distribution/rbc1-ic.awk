#!/usr/bin/awk -f

# place one rbc around cylinder

BEGIN {
    
    tr_shift = 0.2
    xh = yh = zh = Lx
    obj_ry    = Lx/4
    
    xl = yl = zl = 0
    l_element_x = Lx
    
    xc  = (xl + xh)/2;
    yc  = (yl + yh)/2;
    zc  = (zl + zh)/2;
    
    x = xc + l_element_x * tr_shift
    y = (yc + obj_ry + yh)/2
    z = zc
    
    printf "0.000000 0.000000 0.000000\n"
    printf "1.000000 0.000000 0.000000 %g\n", x
    printf "0.000000 1.000000 0.000000 %g\n", y
    printf "0.000000 0.000000 1.000000 %g\n", z
    printf "0.000000 0.000000 0.000000 1.0000000\n"

    printf "(rbc1-ic.awk) x, y, z: %g %g %g\n", x, y, z > "/dev/stderr"
}
