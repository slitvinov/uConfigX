#!/usr/bin/env gawk -f

# Split ply file into parts by the number of vertices `Nv'
# vertices from 1      to   `Nv' go to file1,
# vertices from `Nv'+1 to 2*`Nv' go to file2
# ...

# Usage:
# awk -v Nv=1442 -f scripts/plysplit.awk  rbcs.txt.ply
#
# TEST: plysplit1
# make
# ./ply2ascii < examples/rbcs-0000.ply > examples/rbcs.txt.ply
# scripts/plysplit.awk -v Nv=1442 examples/rbcs.txt.ply
# cat f.00000[012].ply                 > split.out.txt
# rm  f.00000[012].ply
#
# TEST: plysplit2
# scripts/plysplit.awk -v Nv=12 test_data/icosahedron.ply
# mv f.000000.ply split.out.txt

function init(    opat_default) {
    if (!length(Nv)) {
	printf "(plysplit.awk)(ERROR) `Nv' is not set\n" > "/dev/stderr"
	exit
    }

    opat_default = "f.%06d.ply" # output file name pattern
    opat = opat ? opat : opat_default
}

function fn(i) { # file name
    return sprintf(opat, i)
}

function integerp(n)  { # integer predicate
    return n == int(n)
}

function read_header(    sep, Nf_total) { # sets global variables
				          # `head', `Nv_total',
				          # `Npart` (number of parts),
				          # `Nf` (number of faces in
				          # one part)
    header = ""
    while (getline < infile > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") {
	    Nv_total = $3
	    Npart = Nv_total / Nv
	    $3 = Nv
	    if (!integerp(Npart)) {
		printf "(plysplit.awk)(ERROR) `Nv_total/Nv is not integer' \n" > "/dev/stderr"
		printf "(plysplit.awk)(ERROR) Nv = %g, Nv_total = %g, Npart = %g\n",
		    Nv, Nv_total, Npart > "/dev/stderr"
		exit
	    }
	    printf "(plysplit.awk) splitting into %d parts\n", Npart > "/dev/stderr"
	} else if ($1 == "element" && $2 == "face") {
	    Nf_total = $3
	    Nf = Nf_total/Npart
	    $3 = Nf
	}
	sep = header ? "\n" : ""
	header = header sep $0
    }
    header = header sep $0
}

function write_header(    i) {
    for (i=0; i<Npart; i++)
	print header > fn(i)
}

function iv2ipart(iv) {  # file number from vertex number
    return int(iv / Nv)
}

function giv2liv(iv) { # global vertex number to local vertex number
    return     iv % Nv
}

function read_write_vertices(    iv, i) {
    for (iv=0; iv<Nv_total; iv++) {
	getline < infile
	i = iv2ipart(iv)
	print $0 > fn(i)
    }
}

function read_write_faces(      fst, i) {
    while (getline < infile > 0) {
	fst = $2;  i = iv2ipart(fst)
	print $1, giv2liv($2), giv2liv($3), giv2liv($4) > fn(i)
    }
}

BEGIN {
    init()

    if (ARGC < 2)
	infile = "-" # use `stdin'
    else {
	infile = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_header()
    write_header()
    read_write_vertices()
    read_write_faces()
}
