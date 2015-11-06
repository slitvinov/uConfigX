#!/usr/bin/awk -f

# approximatly does solve Nearest neighbor search (NNS)
# 
# Usage:
# `xl', `xh', `yl', `yh', `zl', `zh': bounding box (assumed periodic
# in all directions)
# `c': cutoff for the grid used by the algorithm
# scripts/nns.awk -v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24 -v c=3.0 <file1> <file2>
# Ouptut file:
# id1
# id2
# ..
# idn
# where `idn' is id of the point in file <file1> corresponding to
# point `n' in <file2>
#
# TEST: nns1
# box='-v xl=0 -v xh=10 -v yl=0 -v yh=10 -v zl=0 -v zh=10'
# cutoff='-v c=1'
# ur nns.awk $cutoff $box  test_data/nns.in1 test_data/nns.in2 > nns.out.txt
#
# TEST: nns2
# box='-v xl=0 -v xh=10 -v yl=0 -v yh=10 -v zl=0 -v zh=10'
# cutoff='-v c=1'
# ur nns.awk $cutoff $box  test_data/nns.in1 test_data/nns.in3 > nns.out.txt
#
# TEST: nns3
# box='-v xl=0 -v xh=10 -v yl=0 -v yh=10 -v zl=0 -v zh=10'
# cutoff='-v c=1'
# ur nns.awk $cutoff $box  test_data/nns.per.in1 test_data/nns.per.in2 > nns.out.txt
#
# TEST: nns4
# box='-v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24'
# cutoff='-v c=3.0'
# ur nns.awk $cutoff $box test_data/rbcs.nns1 test_data/rbcs.nns2 > nns.out.txt

function init(    xs_string, ys_string, zs_string) {
    req_var(c, "c")
    req_var(xl, "xl"); req_var(xh, "xh")
    req_var(yl, "yl"); req_var(yh, "yh")
    req_var(zl, "zl"); req_var(zh, "zh")
    
    set_box()
    PBC = 0  # periodic boundary conditions
    OBC = 1 # open boundary conditions

    BIG=1e30 # big positive number

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

function  dist(dx, dy, dz) { return sqrt(dx^2+dy^2+dz^2) }
function wdist(dx, dy, dz) { return dist(dwrapx(dx), dwrapy(dy), dwrapz(dz)) }

function set_box_x() {Lx = xh - xl; nx = int(Lx/c); dx = Lx/nx}
function set_box_y() {Ly = yh - yl; ny = int(Ly/c); dy = Ly/ny}
function set_box_z() {Lz = zh - zl; nz = int(Lz/c); dz = Lz/nz}
function set_box()   {set_box_x(); set_box_y(); set_box_z()}

function req_var(v, n) {
    if (length(v)==0) {
	printf "(nns.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
}

# coordinate to grid point
function x2i(x) {Lr=Lx; nr=nx; rl=xl; rh=xh; dr=dx; bc = bcx; return r2ir(x)}
function y2i(y) {Lr=Ly; nr=ny; rl=yl; rh=yh; dr=dy; bc = bcy; return r2ir(y)};
function z2i(z) {Lr=Lz; nr=nz; rl=zl; rh=zh; dz=dz; bc = bcz; return r2ir(z)};
function r2ir(r) {return r2ir1(wrap(r))}

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

function wrapx(r) {rl=xl; rh=xh; Lr=Lx; return wrap(r)}
function wrapy(r) {rl=yl; rh=yh; Lr=Ly; return wrap(r)}
function wrapz(r) {rl=zl; rh=zh; Lr=Lz; return wrap(r)}

function dwrapx(r) {Lr=Lx; return dwrap(r)}
function dwrapy(r) {Lr=Ly; return dwrap(r)}
function dwrapz(r) {Lr=Lz; return dwrap(r)}

function dwrap(r) {
    if      (bc == PBC) return dwrap_pbc(r)
    else if (bc == OBC) return dwrap_open(r)
}
function dwrap_open(r) {return r}
function dwrap_pbc(r) { # enforce periodic boundary
    if       (r<-Lr/2) return dwrap(r+Lr)
    else if  (r>=Lr/2) return dwrap(r-Lr)
    else             return r
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

function gset(wx, wy, wz, np,    nc) { # add a point to a cell link list
    nc=++n[wx,wy,wz]
    g[wx,wy,wz,nc]=np
}

function gget(wx, wy, wz, x, y, z, np,    d, md, mi, x0, y0, z0, nc, ic, ans) {
    nc=n[wx,wy,wz]
    md=BIG; mi=-1;
    for (ic=1; ic<=nc; ic++) {
	n0 = g[wx,wy,wz,ic]
	
	if (!n0) continue
	if (n0 in taken) continue
	x0=xx[n0]; y0=yy[n0]; z0=zz[n0]
	d = wdist(x-x0, y-y0, z-z0)
	
	if (d<md) {md = d; mi = ic}
    }

    if (mi==-1) {
	printf "(nns.awk) cannot find a pair for [np=%s, xyz=[%s, %s, %s], file: %s\n",
	    np, x, y, z, FILENAME  > "/dev/stderr"
	printf "(nns.awk) wxwywz=[%s, %s, %s], n[..]=%s, g[..,1]=%s, taken=%s\n",
	    wx, wy, wz, n[wx,wy,wz], g[wx,wy,wz,1] , taken[g[wx,wy,wz,1]] > "/dev/stderr"
	exit(2)
    }

    ans = g[wx,wy,wz,mi]
    g[wx,wy,wz,mi] = 0
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
    np++
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    x=wrapx(x); y=wrapy(y); z=wrapz(z)
    xx[np]=x; yy[np]=y; zz[np]=z
    
    ix=x2i(x); iy=y2i(y); iz=z2i(z)
    mark_around(ix, iy, iz)
}

function pair_line(   x, y, z, ix, iy, iz) {
    np++
    
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    x=wrapx(x); y=wrapy(y); z=wrapz(z)
    
    ix=x2i(x); iy=y2i(y); iz=z2i(z)
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
