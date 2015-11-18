#!/usr/bin/awk -f

BEGIN {
    obj_margin = 3.0
    N          = 2*Lx
    printf "extent     %d %d %d\n", Lx, Lx, Lx
    printf "N          %d\n", N
    printf "obj_margin %g\n", obj_margin
    printf "ellipse axis XY point xc yc zc radius Lx/4.0 Lx/3.0 angle pi/8\n"
}
