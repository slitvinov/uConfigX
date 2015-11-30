#!/usr/bin/awk -f

# Convert ply to gts format
# Usage:
# awk -f scripts/ply2gts.awk test_data/icosahedron.ply
#
# TEST: ply2gts1
# ur ply2gts.awk test_data/icosahedron.ply > ply2gts.out.gts
#
# TEST: ply2gts2
# make
# ur ply2ascii < test_data/rbc.org.ply | ur ply2gts.awk  > ply2gts.out.gts

function read_header() { # sets `nv' and `nf'
    while (getline < fn > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") nv = $3
	if ($1 == "element" && $2 == "face"  ) nf = $3
    }
}

function read_write_faces(      fst, nvf, iv) {
    while (getline < fn > 0) {
	nvf = $1
	printf "\nplg [n %d]\n", nvf
	for (iv=1; iv<=nvf; iv++)
	    printf "ref [id %d]\n", $(iv+1)
    }
}

function read_vertices(    iv) {  # fills `vert'
    for (iv=1; iv<=nv; iv++) {
	getline < fn
	vert[iv] = $0
    }
}

function map_edges(    ifa, id1, id2, id3) {
    for (ifa=1; ifa<=nf; ifa++) {
	getline < fn
	id1=$2; id2=$3; id3=$4
	# face[ifa] = edge_id(id3, id1) " " edge_id(id1, id2) " " edge_id(id2, id3)
	# invert faces (looks better in meshlab)
	face[ifa] = edge_id(id3, id2) " " edge_id(id2, id1) " " edge_id(id1, id3)
    }

    ne = ie # number of edges
}

function edge_id(id1, id2) { # updates `ie', `edges' and `i2e'
    if ((id1, id2) in edges)
	return edges[id1, id2]

    ie++ # register a new edge
    edges[id1,id2] = edges[id2,id1] = ie
    i2e[ie] = (id1 + 1) " " (id2 + 1) # gts file has 1-based indexes

    return ie
}

function print_header() {print nv, ne, nf}
function print_vertices(    iv) {
    for (iv=1; iv<=nv; iv++)
	print vert[iv]
}

function print_edges(   ie) {
    for (ie=1; ie<=ne; ie++)
	print i2e[ie]
}

function print_faces(   ifa) {
    for (ifa=1; ifa<=nf; ifa++)
	print face[ifa]
}

BEGIN {
    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_header()
    read_vertices()
    map_edges() # read `faces' and map edges

    print_header()
    print_vertices()
    print_edges()
    print_faces()
}


