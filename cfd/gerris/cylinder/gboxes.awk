#!/usr/bin/awk -f

# Generate boxes for gerris simulations
# Substitute %head%, %box%, %connect%

function init(    xs_string, ys_string, zs_string, d_string) { # sets `xs', `ys', `zs', `d', and `ds'
    NONE = -1

    if (d2) {
	xs_string = "1 0"
	ys_string = "0 1"
	d_string  = "right top"
    } else {
	xs_string = "1 0 0"
	ys_string = "0 1 0"
	zs_string = "0 0 1"
	d_string  = "right top front"
    }

    ns=split(xs_string, xs)
    ns=split(ys_string, ys)
    ns=split(zs_string, zs)
    ns=split(d_string ,  d)

    RefineSolid = Refine + 1
    set_var("Refine",      Refine)
    set_var("RefineSolid", RefineSolid)

    phi = pshift == "inf" ? 0 :  atan2(-1/pshift, 1)
    Fu = Fabs*cos(phi)
    Fv = Fabs*sin(phi)
    set_var("Fu",      Fu) # body force components
    set_var("Fv",      Fv) # 
    
    set_var("R",        R) 
    set_var("Rd",      Rd) # droplet radius

    set_var("yd",      yd) # position of a droplet
    
    set_var("st",      st) # surface tension coefficient
    set_var("ed",      ed) # droplet viscosity
    
}

BEGIN {
    init()
}

function wr_pbc(r) { # wrap if periodic
    return  r ==    0 ? nr : \
	    r == nr+1 ? 1  : \
	    r
}

function wr_open(r) { # wrap if open
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

function wx(r) {return BCX=="pbc" ? wx_pbc(r) : wx_open(r)}
function wy(r) {return BCY=="pbc" ? wy_pbc(r) : wy_open(r)}
function wz(r) {return BCZ=="pbc" ? wz_pbc(r) : wz_open(r)}

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
    ++nbox
    box[ix,iy,iz]=nbox
    posx[nbox] = ix; posy[nbox] = iy; posz[nbox] = iz
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
	    for (iz=1; iz<=nz; iz++)
		for (n=1; n<=ns; n++) { # walk over potential neighbours
		    set_nn(ix, iy, iz, n)
		    if (openp(jx, jy, jz)) continue
		    reg_connect(ix, iy, iz, jx, jy, jz, dir)
		}
}

function decode_connect(iconnect,    line, arr) { # set `id1', `id2'
						  # and `dir'
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
    return (bc == "pbc" && n>1) ? 3/2 : 1/2
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
    sx += get_shift(BCX, nx)
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
	if (d2) {
	    set_domain_bc2d(ibox)
	    printf "GfsBox { pid = %d\n" \
		"%s%s%s%s}\n", \
		pid, bc_top, bc_bottom, bc_left, bc_right
	} else {
	    set_domain_bc3d(ibox)
	    printf "GfsBox { pid = %d\n" \
		"%s%s%s%s}\n", \
		pid, bc_top, bc_bottom, bc_left, bc_right, bc_front, bc_back
	}
    }
}

function set_domain_bc2d(ibox,    ix, iy) {
    ix = posx[ibox]; iy = posy[ibox]
    bc_right  = (ix==nx && BCX=="noslip") ? "  right = Boundary { BcDirichlet V 0 }\n" : ""
    bc_left   = (ix== 1 && BCX=="noslip") ? "  left  = Boundary { BcDirichlet V 0 }\n" : ""
    
    bc_top    = (iy==ny && BCY=="noslip") ? "    top = Boundary { BcDirichlet U 0 }\n" : ""
    bc_bottom = (iy== 1 && BCY=="noslip") ? " bottom = Boundary { BcDirichlet U 0 }\n" : ""
}

function set_domain_bc3d(ibox,    ix, iy, iz) {
    ix = posx[ibox]; iy = posy[nbox]; iz = posy[nbox]
    bc_right  = (ix==nx && BCX=="noslip") ? "  right = Boundary {BcDirichlet V 0\nBcDirichlet W 0}\n" : ""
    bc_left   = (ix== 1 && BCX=="noslip") ? "  left  = Boundary {BcDirichlet V 0\nBcDirichlet W 0}\n" : ""

    bc_top    = (iy==ny && BCY=="noslip") ? "    top = Boundary {BcDirichlet U 0\nBcDirichlet W 0}\n" : ""
    bc_bottom = (iy== 1 && BCY=="noslip") ? " bottom = Boundary {BcDirichlet U 0\nBcDirichlet W 0}\n" : ""
    
    bc_right  = (iz==nz && BCZ=="noslip") ? "  front = Boundary {BcDirichlet U 0\nBcDirichlet V 0}\n" : ""
    bc_left   = (iz== 1 && BCZ=="noslip") ? "  back  = Boundary {BcDirichlet U 0\nBcDirichlet V 0}\n" : ""
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

function set_var(n, v) {
    vlist["%" n "%"] = v
}

function set_vars(   Lx, Ly, Lz, xc, yc, zc) {
    Lx = nx; Ly = ny; Lz = nz
    xc = sx + Lx/2; yc = sy + Ly/2; zc = sz + Lz/2
    set_var("Lx", Lx); set_var("Ly", Ly); set_var("Lz", Lz)
    set_var("xc", xc); set_var("yc", yc); set_var("zc", zc)
}

function sub_vars(   n, v) {
    for (n in vlist) {
	v = vlist[n]
	gsub(n, v)
    }
}

$1 == "%head%" {
    nx =    length(nx)    ? 1     : $2
    ny =    length(ny)    ? 1     : $3
    nz =    length(nz)    ? 1     : $4
    nproc = length(nproc) ? nproc : 1 # number of processors
    process()
	
    print_head()
    set_vars()
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
    BCX = $2
    BCY = $3
    if (!d2)
	BCZ = $4
    next
}

{
    sub_vars()
    print
}
