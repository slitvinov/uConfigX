#!/usr/bin/awk -f

# Transform coordinates in gts file. Currently only scaling is
# supported
#
# Refs:
# http://gts.sourceforge.net/reference/gts-surfaces.html#GTS-SURFACE-WRITE
# http://gts.sourceforge.net/samples.html

function req_var(v, n) {
    if (length(v)) return
    printf "(ply2ext.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	n, n
    exit 2
}

function read_write_header() {
    getline < fn
    nv = $1; ne = $2; nf = $3 #  number of vertices, number of edges,
			      #  number of faces
    print
}

function transform() { # uses `x0', `y0', `z0', sets `x', `y', `z'
    x = sc*x0; y = sc*y0; z = sc*z0
}

function read_write_vert(    iv) {
    for (iv=1; iv<=nv; iv++) {
	getline < fn
	x0 = $1; y0 = $2; z0 = $3
	transform()
	print x, y, z
    }
}

function read_write_rest() {
    while (getline < fn > 0)
	print
}

BEGIN {
    GTS_COMMENTS="#!"      # TODO:
    
    req_var(sc, "sc") # scale

    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }
    
    read_write_header()
    read_write_vert()
    read_write_rest()
}
