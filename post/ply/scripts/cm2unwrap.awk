#!/usr/bin/awk -f

function init() {
    # In maxima:
    # (%i1) L: listify(cartesian_product ({-1, 0, 1}, {-1, 0, 1}, {-1, 0, 1}))$
    # (%i2) printf(true, "\"~{~d ~}\"~%", map('first, L))$
    # (%i3) printf(true, "\"~{~d ~}\"~%", map('second, L))$
    # (%i4) printf(true, "\"~{~d ~}\"~%", map('third, L))$
    xs_string = "-1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1"
    ys_string = "-1 -1 -1 0 0 0 1 1 1 -1 -1 -1 0 0 0 1 1 1 -1 -1 -1 0 0 0 1 1 1"
    zs_string = "-1 0 1 -1 0 1 -1 0 1 -1 0 1 -1 0 1 -1 0 1 -1 0 1 -1 0 1 -1 0 1"

    ns=split(xs_string, xs)
    ns=split(ys_string, ys)
    ns=split(zs_string, zs)

    x_idx = 1; y_idx = 2; z_idx = 3
    imgx_idx = 5; imgy_idx = 6; imgz_idx = 7 # where image flags are
}

function dist(dx, dy, dz) { return sqrt(dx^2+dy^2+dz^2) }

function force_num(x) { return x+0 }

function set_box()   {
    Lx = xh - xl; Ly = yh - yl; Lz = zh - zl
}

BEGIN {
    init()
    set_box()
}

function update_img(x, y, z, xp, yp, zp, xr, yr, zr, i) {
    md = 1e30; mi=1
    for (i=1; i<=ns; i++) {
	xr = x - Lx*xs[i]
	yr = y - Ly*ys[i]
	zr = z - Lz*zs[i]
	d = dist(xp-xr, yp-yr, zp-zr)
	if (d<md) {md = d; mi = i}
    }

    imgx[np]-=xs[mi]; imgy[np]-=ys[mi]; imgz[np]-=zs[mi]
}

FNR == 1 && NR != 1 {
    ifile++
    np=0
}

ifile == 0 { # first file
    np++
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    xx[np]=x; yy[np]=y; zz[np]=z

    ix=force_num($(imgx_idx)); iy =force_num($(imgy_idx)); iz=force_num($(imgz_idx))
    imgx[np]=ix; imgy[np]=iy; imgz[np]=iz
}

ifile == 1 { # second file
    np++
    x = $(x_idx); y = $(y_idx); z = $(z_idx)
    update_img(x, y, z, xx[np], yy[np], zz[np])
    $(imgx_idx)=imgx[np]; $(imgy_idx)=imgy[np]; $(imgz_idx)=imgz[np]

    print
}
