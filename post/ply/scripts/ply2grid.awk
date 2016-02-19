#!/usr/bin/awk -f

# Convert ply to vtk polydata (keep only vertices)
# Usage:
# awk -f scripts/ply2trbc.awk test_data/icosahedron.ply
#

function init() {
    req_var(c, "c")
    req_var(xl, "xl"); req_var(xh, "xh")
    req_var(yl, "yl"); req_var(yh, "yh")
    req_var(zl, "zl"); req_var(zh, "zh")
    
    set_box()
    PBC = 0  # periodic boundary conditions
    OBC = 1 # open boundary conditions

    bcx = bcy = bcz = PBC
}

function req_var(v, n) {
    if (length(v)==0) {
	printf "(ply2grid.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
}

function set_box_x() {Lx = xh - xl; nx = int(Lx/c); dx = Lx/nx}
function set_box_y() {Ly = yh - yl; ny = int(Ly/c); dy = Ly/ny}
function set_box_z() {Lz = zh - zl; nz = int(Lz/c); dz = Lz/nz}
function set_box()   {set_box_x(); set_box_y(); set_box_z()}

function read_header() {
    while (getline < infile > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") Nv = $3
	if ($1 == "element" && $2 == "face"  ) nf = $3	
    }
}

function read_vertices(    iv, x, y, z) { # fills xx, yy, zz
    for (iv=0; iv<Nv; iv++) {
	getline < infile
	x = $1; y = $2; z = $3
	xx[iv] = x; yy[iv] = y; zz[iv] = z
    }
    Nv_out = Nv
}


function read_faces(    ifa, id1, id2, id3,
			x1, y1, z1,
			x2, y2, z2,
			x3, y3, z3,
			xc, yc, zc) {
    for (ifa=1; ifa<=nf; ifa++) {
	getline < infile
	id1 = $2; id2 = $3; id3 = $4
	x1 = xx[id1]; y1 = yy[id1]; z1 = zz[id1]
	x2 = xx[id2]; y2 = yy[id2]; z2 = zz[id2]
	x3 = xx[id3]; y3 = yy[id3]; z3 = zz[id3]
	xc=1/3*(x1+x2+x3); yc=1/3*(y1+y2+y3); zc=1/3*(z1+z2+z3)
	xx[Nv_out] = xc; yy[Nv_out] = yc; zz[Nv_out] = zc
	Nv_out++
    }
}


function project_vertices( ) {
    for (iv=0; iv<Nv_out; iv++) {
	x = xx[iv]; y = yy[iv]; z = zz[iv]
	ix = x2i(x); iy = y2i(y)
	g[ix,iy]++
    }
}

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

function write_header() {
    printf "# vtk DataFile Version 2.0\n"
    printf "Created with v0.awk\n"
    printf "ASCII\n" # ASCII, BINARY
}

function write_topology() {
    printf "DATASET STRUCTURED_POINTS\n"
    printf "DIMENSIONS %d %d %d\n", nx, ny,   1
    printf "ORIGIN %g %g %g\n"    , xlo, ylo, zlo
    printf "SPACING %g %g %g\n"   , dx, dy, dz
}

function write_data(   dataName, dataType, i, j) {
    dataName = "d"
    dataType = "float"
    
    printf "POINT_DATA %d\n", nx*ny
    printf "SCALARS %s %s\n", dataName, dataType
    printf "LOOKUP_TABLE default\n"

    for (j=0; j<ny; j++)
	for (i=0; i<nx; i++)
	    printf "%g\n", g[i,j]
}

BEGIN {
    if (ARGC < 2)
	infile = "-" # use `stdin'
    else {
	infile = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }
    
    init()

    read_header()
    read_vertices()
    read_faces()

    project_vertices()

    write_header()
    write_topology()
    write_data()
}
