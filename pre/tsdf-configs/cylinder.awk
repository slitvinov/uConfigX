#!/usr/bin/awk -f

BEGIN {
    obj_margin = 3.0
    N          = 2*Lx
    printf "extent     %d %d %d\n", Lx, Ly, Lz
    printf "N          %d\n", N
    printf "obj_margin %g\n", obj_margin
    printf "cylinder axis 0 0 1 point xc yc zc radius Lx/2.0\n"
}
