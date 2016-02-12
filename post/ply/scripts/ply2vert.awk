#!/usr/bin/awk -f

# Convert ply to vtk polydata (keep only vertices)
# Usage:
# awk -f scripts/ply2trbc.awk test_data/icosahedron.ply
#
# TEST: ply2vert1
# ur ply2vert.awk examples/tetrahedron.ply > vert.out.vtk

function read_header() {
    while (getline < infile > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") Nv = $3
	if ($1 == "element" && $2 == "face"  ) nf = $3	
    }
}

function write_header() {
    printf "# vtk DataFile Version 2.0\n"
    printf "Created with ply2vert.awk\n"
    printf "ASCII\n"
    printf "DATASET POLYDATA\n"
    printf "POINTS %d float\n", Nv_out
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

function write_vertices(   iv) {
    for (iv=0; iv<Nv_out; iv++)
	print xx[iv], yy[iv], zz[iv]
}

function write_rest(   iv, i) {
    printf "VERTICES 1 %d\n", Nv_out+1
    printf "%d\n", Nv_out
    for (iv=0; iv<Nv_out; iv++)
	print iv
}

BEGIN {
    if (ARGC < 2)
	infile = "-" # use `stdin'
    else {
	infile = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_header()
    read_vertices()
    read_faces()

    write_header()
    write_vertices()    
    write_rest()
}


