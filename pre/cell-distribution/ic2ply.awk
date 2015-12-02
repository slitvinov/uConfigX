#!/usr/bin/awk -f
#
# Generate a single ply file from <cell template file> and <initical
# conditions (IC) file>
# Usage:
# ./ic2ply.awk <cell template> <IC>       > out.ply
#
# TEST: ic2ply1
# ur ic2ply.awk test_data/rbc.org.dat test_data/ic1.dat     >    ic.out.ply
#
# TEST: ic2ply2
# ur ic2ply.awk test_data/rbc.org.dat test_data/ic2.dat     >    ic.out.ply
#
# TEST: ic2ply3
# ur ic2ply.awk test_data/rbc.org.dat test_data/ic3.dat     >    ic.out.ply


function skip_until(fi, pat) {
    while (getline < fi > 0 && $1 != pat)
	;
}

function read_atoms(fi) { # sets `nv' (number of vertices)
    nv=0
    while (getline < fi > 0 && NF != 0) {
	xx[nv]=$4; yy[nv]=$5; zz[nv]=$6 # 0-based indexing
	nv++
    }
}

function read_angles(fi) { # sets `nf' (number of faces)
    nf=0
    while (getline < fi > 0 && NF != 0) {
	id1[nf]=$3; id2[nf]=$4; id3[nf]=$5 # 0-based indexing
	nf++
    }
}

function parse_tmpl() {
    skip_until(tmpl, "Atoms")
    getline < tmpl
    read_atoms(tmpl)

    skip_until(tmpl, "Angles")
    getline < tmpl
    read_angles(tmpl)
}

function transform(    x0, y0, z0, i, X, Y, Z, D) { # update `x', `y' and `z'
    x0=x; y0=y; z0=z
    X = 0; Y = 1; Z = 2; D = 3

    x = M[X,X]*x0 + M[X,Y]*y0 + M[X,Z]*z0 + M[X,D]
    y = M[Y,X]*x0 + M[Y,Y]*y0 + M[Y,Z]*z0 + M[Y,D]
    z = M[Z,X]*x0 + M[Z,Y]*y0 + M[Z,Z]*z0 + M[Z,D]
}

function dep_vertices(    iv) {
    for (iv=0; iv<nv; iv++) {
	x = xx[iv]; y = yy[iv]; z = zz[iv]
	transform()
	vlines[nvlines++] = x " " y " " z
    }
}

function dep_faces(    ifa) {
    for (ifa=0; ifa<nf; ifa++)
	flines[nflines++] = 3 " " id1[ifa] + id_shift " " id2[ifa] + id_shift " " id3[ifa] + id_shift
}

function dep_obj() { # deposit object
    dep_vertices()
    dep_faces()
    id_shift+=nv # shift ids in vertices definition
}

function print_header() {
    printf "ply\n"
    printf "format ascii 1.0\n"
    printf "comment created by ic2ply\n"
    printf "element vertex %d\n", nvlines
    printf "property float32 x\n"
    printf "property float32 y\n"
    printf "property float32 z\n"
    printf "element face %d\n", nflines
    printf "property list uint8 int32 vertex_indices\n"
    printf "end_header\n"
}

function print_vertices(    iv) {
    for (iv=0; iv<nvlines; iv++)
	print vlines[iv]
}

function print_faces(    ifa) {
    for (ifa=0; ifa<nflines; ifa++)
	print flines[ifa]
}

function print_ply() {
    print_header()
    print_vertices()
    print_faces()
}

function next_matrix(    oRS, nr, aux, i, j, idx) { # get next matrix `M' from IC file
    nneed = 3 + 4*4 # 3 dummy + 4x4 matrix
    oRS = RS; RS="[ \t\n]"
    while (nr<nneed && getline < ic > 0)
	if (NF>0) aux[nr++]=$1 # 0-based indexing
    RS = oRS
    if (nr != nneed)
	return 0 # cannot get the matrix

    idx = 3 # skip 0, 1 and 2
    for (i=0; i<4; i++)
	for (j=0; j<4; j++)
	    M[i,j] = aux[idx++] # 0-based indexing for matrix
    return 1
}

BEGIN {
    tmpl = ARGV[1]
    ic   = ARGV[2]

    parse_tmpl()
    while (next_matrix())
	dep_obj()
    print_ply()
    
    exit
}
