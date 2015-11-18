#!/usr/bin/awk -f

function init() {
    x_idx = 1; y_idx = 2; z_idx = 3
    imgx_idx = 5; imgy_idx = 6; imgz_idx = 7 # where image flags are
}

function force_num(x) { return x+0 }
function set_box()   {
    Lx = xh - xl; Ly = yh - yl; Lz = zh - zl
}

BEGIN {
    init()
    set_box()
}

/./ {
    x  = $(x_idx); y = $(y_idx); z = $(z_idx)
    ix=force_num($(imgx_idx)); iy =force_num($(imgy_idx)); iz=force_num($(imgz_idx))

    $(x_idx) = x + Lx*ix; $(y_idx) = y + Ly*iy; $(z_idx) = z + Lz*iz
    print
}
