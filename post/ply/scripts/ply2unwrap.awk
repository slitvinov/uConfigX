#!/usr/bin/awk -f

# Calculate the center of mass (CM) and the velocity of CM of each
# object in itrangulated ply file

# Usage:
# awk -v Nv=1442 -f scripts/ply2unwrap.awk  rbcs.txt.ply
# 42     : small
# 92, 162: intermediate
# 362    : big
# 812    : too big

function init(    opat_default) {
    if (!length(Nv)) {
	printf "(ply2unwrap.awk)(ERROR) `Nv' is not set\n" > "/dev/stderr"
	exit
    }

    imgx_idx = 5; imgy_idx = 6; imgz_idx = 7 # where image flags are
}

function integerp(n)  { # integer predicate
    return n == int(n)
}

function read_write_header(    sep, Nf_total, Npart) { # sets global variables
				          # `Nv_total', (number of
				          # parts), `Nf` (number of
				          # faces in one part)
    while (getline < infile > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") {
	    Nv_total = $3
	    Npart = Nv_total / Nv
	    if (!integerp(Npart)) {
		printf "(ply2unwrap.awk)(ERROR) `Nv_total/Nv is not integer' \n" > "/dev/stderr"
		printf "(ply2unwrap.awk)(ERROR) Nv = %g, Nv_total = %g, Npart = %g\n",
		    Nv, Nv_total, Npart > "/dev/stderr"
		exit
	    }
	    printf "(ply2unwrap.awk) found %d parts\n", Npart > "/dev/stderr"
	}
	print
    }
    print
}

function iv2ipart(iv) {  # file number from vertex number
    return int(iv / Nv)
}

function read_write_vertices(    iv, i, index_img, ix, iy, iz, iprev, x, y, z) {
    iprev = 0
    for (iv=0; iv<Nv_total; iv++) {
	i = iv2ipart(iv)
	index_img = i + 1
	getline < infile
	x  = $1;  y = $2;  z = $3
	ix = imgx[index_img]; iy = imgy[index_img]; iz = imgz[index_img];
	$1 = x + ix*Lx; $2 = y + iy*Ly; $3 = z + iz*Lz
	print
    }
}

function set_box()   {
    Lx = xh - xl; Ly = yh - yl; Lz = zh - zl
}

function read_map(    np, oid) {
    while (getline < mapfile > 0) {
	oid = $4
	imgx[oid] = $(imgx_idx); imgy[oid] = $(imgy_idx); imgz[oid] = $(imgz_idx)
    }
}

function read_write_rest() {
    while (getline < infile > 0)
	print
}

BEGIN {
    init()
    set_box()


    mapfile = ARGV[1]  # read file implicitly
    ARGV[1] = ""

    read_map()

    infile = ARGV[2] # read file implicitly
    ARGV[2] = ""

    read_write_header()
    read_write_vertices()

    read_write_rest()
}
