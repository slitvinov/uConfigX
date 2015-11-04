#!/usr/bin/awk -f

# Convert ply to trbc format
# Usage:
# awk -f scripts/ply2trbc.awk test_data/icosahedron.ply
#
# TEST: ply2trbc1
# ur ply2trbc.awk test_data/cube.ply > cube.out.trbc

function read_header() {
    while (getline < infile > 0 && $0 != "end_header" )
	if ($1 == "element" && $2 == "vertex") Nv = $3
}

function read_vertices(    iv, i) {
    for (iv=0; iv<Nv; iv++) {
	getline < infile
	print "def [id " iv "] [pos " $0 "]"
    }
}

function read_write_faces(      fst, nvf, iv) {
    while (getline < infile > 0) {
	nvf = $1
	printf "\nplg [n %d]\n", nvf
	for (iv=1; iv<=nvf; iv++)
	    printf "ref [id %d]\n", $(iv+1)
    }
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
    read_write_faces()
}


