#!/usr/bin/awk -f

# generate files with location for OutputLocation (see
# script.templ.gfs)

# generates prof.xl, prof.xc, prof.yl, prof.yc files

function prof_xl(   ip, x, y, z, dy, f) {
    f = d "/prof.xl"
    x=0; dy = Ly/(np - 1); z=zc
    for (ip=0; ip<np; ip++) {
	y = dy*ip
	print x, y, z        > f
    }
    close(f)
}

function prof_xc(   ip, x, y, z, dy, pf) {
    f = d "/prof.xc"
    x=xc; dy = Ly/(np - 1); z=zc
    for (ip=0; ip<np; ip++) {
	y = dy*ip
	print x, y, z        > f
    }
    close(f)
}

function prof_yl(   ip, x, y, z, dx, pf) {
    f = d "/prof.yl"
    dx = Lx/(np - 1); y=0; z=zc
    for (ip=0; ip<np; ip++) {
	x = dx*ip
	print x, y, z        > f
    }
    close(f)
}

function prof_yc(   ip, x, y, z, dx, pf) {
    f = d "/prof.yc"
    dx = Lx/(np - 1); y=yc; z=zc
    for (ip=0; ip<np; ip++) {
	x = dx*ip
	print x, y, z        > f
    }
    close(f)
}

BEGIN {
    d = length(d) ? d : "."
    np = 100
    
    nx = 64
    ny = 64
    nz = 0

    Lx = nx; Ly = ny; Lz = nz
    xc = Lx/2; yc = Ly/2; zc=Lz/2

    prof_xl()
    prof_xc()

    prof_yl()
    prof_yc()
}



