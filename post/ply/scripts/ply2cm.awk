#!/usr/bin/awk -f

# Calculate the center of mass (CM) and the velocity of CM of each
# object in itrangulated ply file
#
# Usage:
# awk -v Nv=1442 -f scripts/ply2cm.awk  rbcs.txt.ply
#
# TEST: cm1
# ur ply2cm.awk -v Nv=8 test_data/cube.ply  > cm.out.txt
# 
# TEST: cm2
# make
# ur ply2ascii < test_data/rbcs-0001.ply | ur ply2cm.awk -v Nv=162 > cm.out.txt
#

function init(    opat_default) {
    X = 0; Y = 1; Z = 2
    
    if (!length(Nv)) {
	printf "(ply2cm.awk)(ERROR) `Nv' is not set\n" > "/dev/stderr"
	exit
    }
}

function integerp(n)  { # integer predicate
    return n == int(n)
}

function read_header(    sep, Nf_total, Npart) { # sets global variables
				          # `Nv_total', (number of
				          # parts), `Nf` (number of
				          # faces in one part)
    while (getline < infile > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") {
	    Nv_total = $3
	    Npart = Nv_total / Nv
	    $3 = Nv
	    if (!integerp(Npart)) {
		printf "(ply2cm.awk)(ERROR) `Nv_total/Nv is not integer' \n" > "/dev/stderr"
		printf "(ply2cm.awk)(ERROR) Nv = %g, Nv_total = %g, Npart = %g\n",
		    Nv, Nv_total, Npart > "/dev/stderr"
		exit
	    }
	    printf "(ply2cm.awk) %d parts, %d total\n", Npart, Nv_total > "/dev/stderr"
	}
    }
}

function iv2ipart(iv) {  # file number from vertex number
    return int(iv / Nv)
}

function cm_flush(cm) {
    print cm[X]/Nv,   cm[Y]/Nv, cm[Z]/Nv
     cm[X] =  cm[Y] =  cm[Z] = 0
}

function read_vertices(    iv, i, iprev, x, y, z) {
    iprev = 0
    for (iv=0; iv<Nv_total; iv++) {
	i = iv2ipart(iv)
	if (iprev != i) {
	    iprev = i
	    cm_flush(cm)
	}
	getline < infile
	x  = $1;  y = $2;  z = $3
	 cm[X]+=x;   cm[Y]+=y;   cm[Z]+=z
    }
    cm_flush(cm)
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
    read_vertices()
}
