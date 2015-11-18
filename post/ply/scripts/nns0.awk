#!/usr/bin/awk -f

# exact Nearest neighbor search (NNS) for one point
# 
# Usage: `xl', `xh', `yl', `yh', `zl', `zh': bounding box (assumed
# periodic in all directions)

function init(    xs_string, ys_string, zs_string, arr) {
    req_var(id, "id")
    req_var(xl, "xl"); req_var(xh, "xh")
    req_var(yl, "yl"); req_var(yh, "yh")
    req_var(zl, "zl"); req_var(zh, "zh")
    
    set_box()
    PBC = 0  # periodic boundary conditions
    OBC = 1 # open boundary conditions

    BIG=1e20 # big positive number

    bcx = bcy = bcz = PBC

    min_dist = BIG
    mid      = -1
}

function  dist(dx, dy, dz) { return sqrt(dx^2+dy^2+dz^2) }
function wdist(dx, dy, dz) { return dist(dwrapx(dx), dwrapy(dy), dwrapz(dz)) } # "wraped"
                                                                               # distance
                                                                               # dist
                                                                               # to
                                                                               # closes
                                                                               # periodic
                                                                               # image

function set_box_x() {Lx = xh - xl}
function set_box_y() {Ly = yh - yl}
function set_box_z() {Lz = zh - zl}
function set_box()   {set_box_x(); set_box_y(); set_box_z()}

function req_var(v, n) {
    if (length(v)==0) {
	printf "(nns.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
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

function pair_line(   x, y, z, ix, iy, iz) {
    np++
    
    x=$(x_idx); y=$(y_idx); z=$(z_idx)
    x=wrapx(x); y=wrapy(y); z=wrapz(z)
    
    ix=x2i(x); iy=y2i(y); iz=z2i(z)
    print gget(ix, iy, iz, x, y, z, np)
}

FNR == 1 && NR != 1 {
    ifile++
}

ifile == 0 && FNR == id { # first file
    x0=$1; y0=$2; z0=$3 # "old" position
    print x0, y0, z0
}

ifile > 1 && FNR == 1 {
    print xm, ym, zm
    min_dist = BIG
    mid = -1
    x0 = xm; y0 = ym; z0 = zm
}

ifile > 0 { # rest of the files
    x=$1; y=$2; z=$3
    d = wdist(x-x0, y-y0, z-z0)
    if (d<min_dist) {
	min_dist = d
	mid = FNR
	xm = x; ym = y; zm = z
    }
}

END {
    if (length(xm)>0)
	print xm, ym, zm
}
