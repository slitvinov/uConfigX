#!/usr/bin/awk -f

# Generate boxes for gerris
# Substitute %head%, %box%, %connect%

BEGIN {
    PBC = 1; OPEN = 2
    NONE = -1

    xs_string = "1 0 0"
    ys_string = "0 1 0"
    zs_string = "0 0 1"
    d_string  = "right top front"

    ns=split(xs_string, xs)
    ns=split(ys_string, ys)
    ns=split(zs_string, zs)
    ns=split(d_string ,  d)
}

function wr_pbc(r) {
    return  r ==    0 ? nr : \
	    r == nr+1 ? 1  : \
	    r
}

function wr_open(r) {
    return  r ==    0 ? NONE : \
	    r == nr+1 ? NONE : \
	    r
}

function wx_pbc(r) {nr=nx; return wr_pbc(r)}
function wy_pbc(r) {nr=ny; return wr_pbc(r)}
function wz_pbc(r) {nr=nz; return wr_pbc(r)}

function wx_open(r) {nr=nx; return wr_open(r)}
function wy_open(r) {nr=ny; return wr_open(r)}
function wz_open(r) {nr=nz; return wr_open(r)}

function wx(r) {return BCX==PBC ? wx_pbc(r) : wx_open(r)}
function wy(r) {return BCY==PBC ? wy_pbc(r) : wy_open(r)}
function wz(r) {return BCZ==PBC ? wz_pbc(r) : wz_open(r)}

function set_nn(ix, iy, iz, i) { # set neighbor coordinates `jx', `jy', `jz', `dir'
    jx = ix + xs[i]
    jy = iy + ys[i]
    jz = iz + zs[i]
    dir = d[i]

    jx = wx(jx); jy = wy(jy); jz = wz(jz)
}

function openp(x, y, z) {
    return x==NONE || y==NONE || z == NONE
}

function reg_box(ix, iy, iz) { # updates `nbox'
    if ((ix, iy, iz) in box) return
    box[ix,iy,iz]=++nbox
}

function reg_all_boxes(   ix, jy, iz) {
    for (ix=1; ix<=nx; ix++)
	for (iy=1; iy<=ny; iy++)
	    for (iz=1; iz<=nz; iz++)
		reg_box(ix, iy, iz)
}

function reg_all_connect(    ix, iy, iz) {
    for (ix=1; ix<=nx; ix++)
	for (iy=1; iy<=ny; iy++)
	    for (iz=1; iz<=nz; iz++) {
		for (n=1; n<=ns; n++) { # walk over potential neighbours
		    set_nn(ix, iy, iz, n)
		    if (openp(jx, jy, jz)) continue
		    reg_connect(ix, iy, iz, jx, jy, jz, dir)
		}
	    }
}

function decode_connect(iconnect,    line, arr) {
    line = connect[iconnect]
    split(line, arr, SUBSEP)
    id1 = arr[1]; id2 = arr[2]; dir=arr[3]
}

function reg_connect(ix, iy, iz, jx, jy, jz, dir,   id1, id2) {
    id1=box[ix, iy, iz]
    id2=box[jx, jy, jz]
    connect[++nconnect]= id1 SUBSEP id2 SUBSEP dir
}

function get_shift(bc, n) { # shift the origin
    return (bc == PBC && n>1) ? 3/2 : 1/2
}

function print_shift3d(sx, sy, sz) {
    printf "%d %d GfsSimulation GfsBox "	\
	"GfsGEdge { x = %g y = %g z = %g} {\n",
	nbox, nconnect, sx, sy, sz
}

function print_shift2d(sx, sy) {
    printf "%d %d GfsSimulation GfsBox "	\
	"GfsGEdge { x = %g y = %g} {\n",
	nbox, nconnect, sx, sy
}

function print_head(        sx, sy, sz) {
    sx += get_shift(BCZ, nx)
    sy += get_shift(BCY, ny)
    sz += get_shift(BCZ, nz)
    if (d2)
	print_shift2d(sx, sy)
    else
	print_shift3d(sx, sy, sz)
}

function get_pid(i, n, np,    npo, ans) {
    npo = n/np
    ans = int((i-1)/npo)
    if (ans>np-1)
	ans = np-1

    return ans
}

function print_box(   pid, ibox) {
    for (ibox=1; ibox<=nbox; ibox++) {
	pid = get_pid(ibox, nbox, nproc)
	printf "GfsBox { pid = %d }\n", pid
    }
}

function print_connect(   iconnect) {
    for (iconnect=1; iconnect<=nconnect; iconnect++) {
	decode_connect(iconnect)
	print id1, id2, dir
    }
}

function process() {
    reg_all_boxes()
    reg_all_connect()
}

$1 == "%head%" {
    nx = length(nx) ? nx : $2
    ny = length(ny) ? ny : $3
    nz = length(nz) ? nz : $4
    nproc = length(nproc) || NF < 5 ? nproc : $5
    process()
	
    print_head()
    next
}

$1 == "%box%" {
    print_box()
    next
}

$1 == "%connect%" {
    print_connect()
    next
}

$1 == "%shift%" {
    sx = $2; sy = $3; sz = $4
    next
}

$1 == "%bc%" {
    BCX = $2 == "pbc" ? PBC : OPEN
    BCY = $3 == "pbc" ? PBC : OPEN
    BCZ = $4 == "pbc" ? PBC : OPEN
    next
}

{
    print
}
