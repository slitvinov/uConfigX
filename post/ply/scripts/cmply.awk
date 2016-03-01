#!/usr/bin/awk -f

function init() {
    X = 1; Y = 2; Z = 3
}

function read_write_header() { # sets `nv' and `nf'
    while (getline < fn > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") nv = $3
	print
    }
    print
}


function read_write_faces() {
    while (getline < fn > 0)
	print
}

function reg_vertex(iv) {
     x[iv]=$1;  y[iv]=$2;  z[iv]=$3
    vx[iv]=$4; vy[iv]=$5; vz[iv]=$6
}

function read_vertices(    iv) {  # fills `vert'
    for (iv=0; iv<nv; iv++) {     # zero based
	getline < fn
	reg_vertex(iv)
    }
}

function process_vetices(   iv, xc, yc, zc) {
    for (iv=0; iv<nv; iv++)  {    # zero based
	xc+=x[iv]; yc+=y[iv]; zc+=z[iv]
    }
    xc/=nv; yc/=nv; zc/=nv

    for (iv=0; iv<nv; iv++)  {    # zero based
	x[iv]-=xc; y[iv]-=yc; z[iv]-=zc
    }
}

function print_vertex(iv) {
    print x[iv], y[iv], z[iv], vx[iv], vy[iv], vz[iv]
}

function write_vertices() {
    for (iv=0; iv<nv; iv++)     # zero based
	print_vertex(iv)
}


BEGIN {
    init()
    
    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_write_header()
    
    read_vertices()
    process_vetices()
    write_vertices()

    read_write_faces()
}
