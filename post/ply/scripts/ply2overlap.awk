#!/usr/bin/awk -f

# Approximately find overlap between several ply files
# Usage:
# find test_data -name 'f.00000[012].ply' | scripts/ply2overlap.awk \
#  -v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24 -v c=0.5 > ply2overlap.out.vtk
#
# TEST: ply2overlap1
# make
# box='-v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24'
# cutoff='-v c=0.5'
# find test_data -name 'f.00000[012].ply' | scripts/ply2overlap.awk $box $cutoff > ply2overlap.out.vtk

function init() {
    set_box()
    PBC = 0  # periodic boundary conditions
    OBC = 1 # open boundary conditions

    bcx = bcy = bcz = PBC
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

function read_header() {
    while (getline < infile > 0 && $0 != "end_header" )
	if ($1 == "element" && $2 == "vertex") Nv = $3
}

function read_vertices(    iv) {
    delete xx; delete yy; delete zz
    for (iv=0; iv<Nv; iv++) {
	getline < infile
	xx[iv]=$1; yy[iv]=$2; zz[iv]=$3
    }
}

function set_face(i1, i2, i3) {
    x1=xx[i1]; y1=yy[i1]; z1=zz[i1]
    x2=xx[i2]; y2=yy[i2]; z2=zz[i2]
    x3=xx[i3]; y3=yy[i3]; z3=zz[i3]
}

function reg_point(x, y, z,    ix, iy, iz, sep) {
    ix = x2i(x); iy = y2i(y); iz = z2i(z)
    if (g[ix,iy,iz]==-1) return # already an overlap
    
    if (g[ix,iy,iz]==0)
	g[ix,iy,iz]=ifile
    else if (g[ix,iy,iz]!=ifile) {
	g[ix,iy,iz]=-1 	# we found an overlap
	opoints[n_over++] = x SUBSEP y SUBSEP z
    }
}

function read_process_faces(    iv, i1, i2, i3) {
    while (getline < infile > 0) {
	i1=$2; i2=$3; i3=$4
	set_face(i1, i2, i3)
	reg_point(x1, y1, z1)
	reg_point(x2, y2, z2)
	reg_point(x3, y3, z3)

	reg_point((x1+x2+x3)/3, (y1+y2+y3)/3, (z1+z2+z3)/3)
	reg_point((x1+x2)/2, (y1+y2)/2, (z1+z2)/2)
	reg_point((x1+x3)/2, (y1+y3)/2, (z1+z3)/2)
	reg_point((x2+x3)/2, (y2+y3)/2, (z2+z3)/2)
    }
}

function read_file() {
    read_header()
    read_vertices()
    read_process_faces()
}

function file_version() {printf "# vtk DataFile Version 2.0\n"}
function header()       {printf "Created with ply2overlap.awk\n"}
function format()       {printf "ASCII\n"}
function topology_grid()     {
    printf "DATASET STRUCTURED_POINTS\n"
    printf "DIMENSIONS %d %d %d\n", nx+1, ny+1, nz+1
    printf "ORIGIN %g %g %g\n"    , xl, yl, zl
    printf "SPACING %g %g %g\n"   , dx, dy, dz
}

function topology_points(    dataType, i, arr)     {
    dataType = "float"
    printf "DATASET POLYDATA\n"
    printf "POINTS %d %s\n", n_over, dataType
    for (i=0; i<n_over; i++) {
	split(opoints[i], arr, SUBSEP)
	print arr[1], arr[2], arr[3]
    }

    printf "VERTICES %d %d\n", 1, n_over+1
    printf "%d\n", n_over
    for (i=0; i<n_over; i++)
	printf "%d\n", i
}

function dataset_grid(    dataName, dataType, i, j, k) {
    dataName = "overlap"
    dataType = "float"

    printf "CELL_DATA %d\n", nx*ny*nz
    printf "SCALARS %s %s\n", dataName, dataType
    printf "LOOKUP_TABLE default\n"
    for (k=0; k<nz; k++)
	for (j=0; j<ny; j++)
	    for (i=0; i<nx; i++)
		printf "%g\n", (g[i,j,k]==-1 ? 1 : 0)
}

function dump_grid() {
    file_version()
    header()
    format()

    topology_grid()
    dataset_grid()
}

function dump_points() {
    file_version()
    header()
    format()

    topology_points()
#    dataset_points()
}

BEGIN {
    init()
}

NF {
    fn = $0 # file name
    flist[++ifile]=fn
}

END {
    nfile = ifile
    for (ifile=1; ifile<=nfile; ifile++) {
	fn = flist[ifile]
	infile = fn; read_file()
    }
    
#    dump_grid()
    dump_points()
}
