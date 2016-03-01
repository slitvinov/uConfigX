#!/usr/bin/awk -f

# Compute energies for the membrain model
# 
# Usage:
# awk -f scripts/ply2energy.awk test_data/icosahedron.ply
#

function init() {
    X = 1; Y = 2; Z = 3
}

function read_header() { # sets `nv' and `nf'
    while (getline < fn > 0 && $0 != "end_header" ) {
	if ($1 == "element" && $2 == "vertex") nv = $3
	if ($1 == "element" && $2 == "face"  ) nf = $3
    }
}

function reg_face(   id1, id2, id3, ifa) { # next
    f1[ifa] = id1; f2[ifa] = id2; f3[ifa] = id3
}

function read_faces(   id1, id2, id3, ifa) {
    ifa = 0
    while (getline < fn > 0) {
	id1 = $2; id2 = $3; id3 = $4
	reg_face(id1, id2, id3, ifa)
	ifa ++
    }
}

function read_vertices(    iv) {  # fills `vert'
    for (iv=0; iv<nv; iv++) {     # zero based
	getline < fn
	vert[iv] = $0
    }
}

function mid(iv) { # map vertices ids from old to new
    return iv - iv_min
}

function cid2vert(cid      ) { # sets `iv_min' and `iv_max'
    iv_min = (cid - 1) * Nv
    iv_max = cid * Nv        # excluding this end
}

function selected(iv) {
    return iv>=iv_min && iv<iv_max
}

function filter_faces(   ifa, id1, id2, id3, ifa_out) { # sets
							# `face_out'
							# and `nf_out'
    for (ifa = 0; ifa<nf; ifa++) {
	id1=f1[ifa]; id2=f2[ifa]; id3=f3[ifa]
	if (selected(id1))
	    face_out[ifa_out++]=sprintf("3 %d %d %d", mid(id1), mid(id2), mid(id3))
    }
    nf_out = ifa_out
}

function write_header() {
    printf "ply\n"
    printf "format ascii 1.0\n"
    printf "element vertex %d\n", nv_out
    printf "property float32 x\n"
    printf "property float32 y\n"
    printf "property float32 z\n"
    printf "property float32 u\n"
    printf "property float32 v\n"
    printf "property float32 w\n"
    printf "element face %d\n", nf_out
    printf "property list int32 int32 vertex_index\n"
    printf "end_header\n"
}

function write_vertices(   iv) {
    for (iv=iv_min; iv<iv_max; iv++)
	print vert[iv]
}

function write_faces( ifa) {
    for (ifa=0; ifa<nf_out; ifa++)
	print face_out[ifa]
}

BEGIN {
    init()
    
    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    Nv = 498
    read_header()

    nc = nv/Nv # total number of cells
    
    read_vertices()
    read_faces()

    cid2vert(cid)
    nv_out = iv_max - iv_min

    filter_faces()
    nf_out /= 10 #!!!!!!!!!!!!!!!!!!!

    write_header()
    write_vertices()
    write_faces()
}
