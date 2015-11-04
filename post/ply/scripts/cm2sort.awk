#!/usr/bin/awk -f

function init() {
    set_box()
    PBC = 0  # periodic boundary conditions
    OBC = 1 # open boundary conditions

    bcx = bcy = bcz = PBC

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
}

function set_box_x() {Lx = xh - xl; nx = int(Lx/c); dx = Lx/nx}
function set_box_y() {Ly = yh - yl; ny = int(Ly/c); dy = Ly/ny}
function set_box_z() {Lz = zh - zl; nz = int(Lz/c); dz = Lz/nz}
function set_box()   {set_box_x(); set_box_y(); set_box_z()}

function print_box() {
    printf "xl xh yl yh zl zh\n"
    printf "%g %g %g %g %g %g\n", xl, xh, yl, yh, zl, zh

    printf "dx dy dz\n"
    printf "%g %g %g\n", dx, dy, dz

    printf "Lx Ly Lz\n"
    printf "%g %g %g\n", Lx, Ly, Lz

    printf "nx ny nz\n"
    printf "%g %g %g\n", nx, ny, nz
}

# coordinate to grid point
function x2i(x) {Lr=Lx; nr=nx; rl=xl; rh=xh; dr=dx; bc = bcx; return r2ir(x)}
function y2i(y) {Lr=Ly; nr=ny; rl=yl; rh=yh; dr=dy; bc = bcy; return r2ir(y)};
function z2i(z) {Lr=Lz; nr=nz; rl=zl; rh=zh; dz=dz; bc = bcz; return r2ir(z)};
function r2ir(r) {return r2ir1(wrap(r))}

# grid point to coordinate
function i2x(i) {rl=xl; dr=dx; return i2r(i)}
function i2y(i) {rl=yl; dr=dy; return i2r(i)}
function i2z(i) {rl=zl; dr=dz; return i2r(i)}
function i2r(i) {return rl + 1/2*dr + dr*i}

function r2ir1(r,    ans) {
    ans = int((r - rl)/dr)
    if      (ans>=nr) ans = nr-1
    else if (ans<0)   ans = 0
    return ans
}

function iwrapx(i) {nr=nx; return iwrap(i)}
function iwrapy(i) {nr=ny; return iwrap(i)}
function iwrapz(i) {nr=nz; return iwrap(i)}

function iwrap(i) {
    if      (bc == PBC) return iwrap_pbc(i)
    else if (bc == OBC) return iwrap_open(i)
}
function iwrap_open(i) {return i}
function iwrap_pbc(i) { # enforce periodic boundary
    if       (i<0)   return iwrap(i+nr)
    else if  (i>=nr) return iwrap(i-nr)
    else             return i
}

function wrap(r) {
    if      (bc == PBC) return wrap_pbc(r)
    else if (bc == OBC) return wrap_open(r)
}

function wrap_open(r) {return r}
function wrap_pbc(r) { # enforce periodic boundary
    if       (r<rl)  return wrap(r+Lr)
    else if  (r>=rh) return wrap(r-Lr)
    else             return r
}

BEGIN {
    init()
}

function gset(wx, wy, wz, np,    nc) {
    nc=++n[wx,wy,wz]
    g[wx,wy,wz,nc]=np
    if (np==1) {
	printf "(%s) gset %s %s %s n[...]=%s\n", FILENAME, wx, wy, wz, n[wx,wy,wz] > "/dev/stderr"
    }
}

function gget(wx, wy, wz, x, y, z, np, nc, ans) {
    do {
	if (np==1) {
	    printf "(%s) gget %s %s %s, nc=%s, ans=%s, np=%s\n", FILENAME, wx, wy, wz, nc, ans, np > "/dev/stderr"
	}
	
	nc = n[wx,wy,wz]
	if (!nc) {
	    printf "(cm2sort.awk) cannot find previous position for np=%g, pos: [%s %s %s]. File: %s\n",
		np, x, y, z, FILENAME > "/dev/stderr"
	    exit
	}
	ans = g[wx,wy,wz,nc]
	n[wx,wy,wz]--
	
    } while (ans in taken)
    
    taken[ans]++
    
    return ans
}

function mark_around(ix, iy, iz,     i,  wx, wy, wz) {
    for (i=1; i<=ns; i++) {
	wx = iwrapx(ix+xs[i]); wy = iwrapy(iy+ys[i]); wz = iwrapz(iz+zs[i])
	gset(wx, wy, wz, np)
    }
}

function reg_line(    x, y, z, ix, iy, iz) {
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    ix=x2i(x); iy=y2i(y); iz=z2i(z)
    np++; mark_around(ix, iy, iz)
}

function pair_line(   x, y, z, ix, iy, iz) {
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    ix=x2i(x); iy=y2i(y); iz=z2i(z)
    np++
    print gget(ix, iy, iz, x, y, z, np)
}

FNR == 1 && NR != 1 {
    ifile++
    np=0
}

ifile == 0 { # first file
    reg_line()
}

ifile == 1 { # second file
    pair_line()
}
