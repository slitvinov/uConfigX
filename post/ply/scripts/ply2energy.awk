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

function face2vect(id1, id2, id3,    a) { # sets id1, id2, id3
    split(vert[id1], a)
    x1=a[X]; y1=a[Y]; z1=a[Z]
    
    split(vert[id2], a)
    x2=a[X]; y2=a[Y]; z2=a[Z]
    
    split(vert[id3], a)
    x3=a[X]; y3=a[Y]; z3=a[Z]
}

function cp(A, B, C) { # cross product in 3D
    C[X] =   A[Y]*B[Z] - A[Z]*B[Y]
    C[Y] = -(A[X]*B[Z] - A[Z]*B[X])
    C[Z] =   A[X]*B[Y] - A[Y]*B[X]
}

function dot(A, B) {
    return A[X]*B[X] + A[Y]*B[Y] + A[Z]*B[Z]
}

function reg_face(   id1, id2, id3, ifa) { # next
    f1[ifa] = id1; f2[ifa] = id2; f3[ifa] = id3
    face_next[id1, id2] = id3
    face_next[id2, id3] = id1
    face_next[id3, id1] = id2
}

function read_faces(   id1, id2, id3, ifa) {
    ifa = 0
    while (getline < fn > 0) {
	id1 = $2; id2 = $3; id3 = $4
	reg_face(id1, id2, id3, ifa)
	# face2vect(id1, id2, id3) 
	# r2a()
	# ksi_v  = cp(a21_v, a31_v),
	# cp(a21, a31, ksi)
	# print tc [X], tc [Y], tc [Z] > "A.txt"
	# print tc [X] - 3*ksi[X], tc [Y] - 3*ksi[Y], tc [Z] - 2*ksi[Z] > "B.txt"
	ifa ++
    }
    nfa = ifa
}

function reg_edge(id1, id2, ied) {
    if ((id2, id1) in _edge) return ied
    ied++
    e1[ied]=id1; e2[ied]=id2; _edge[id1, id2]
    return ied
}

function build_edges(   ifa, id1, id2, id3, ied) { # uses f1, f2, f3,
						  # face_next, sets
						  # `e1', `e2', and
						  # `ned'
    for (ifa=0; ifa<nfa; ifa++) {
	id1=f1[ifa]; id2=f2[ifa]; id3=f3[ifa];
	ied = reg_edge(id1, id2, ied)
	ied = reg_edge(id2, id3, ied)
	ied = reg_edge(id3, id1, ied)
    }
    ned = ied 
}

function build_dihs(   id1, id2, id3, id4, ied) { # sets d1, d2, d3, d3, and `ned'
    for (ied=1; ied<ned; ied++) {
	id1=e1[ied]; id2=e2[ied]; id3=face_next[id1, id2]; id4=face_next[id2, id1]
	d1[ied]=id1; d2[ied]=id2; d3[ied]=id3;             d4[ied]=id4
    }
    
    ndi = ned # the number of dihedrals equal to the number of edges
}

function read_vertices(    iv) {  # fills `vert'
    for (iv=0; iv<nv; iv++) {     # zero based
	getline < fn
	vert[iv] = $0
    }
}

function decode_face(ied,     a, id1, id2, id3) {
    id1 = f1[ied]; id2 = f2[ied]; id3=f3[ied]

    split(vert[id1], a)
    x1=a[X]; y1=a[Y]; z1=a[Z]
    
    split(vert[id2], a)
    x2=a[X]; y2=a[Y]; z2=a[Z]

    split(vert[id3], a)
    x3=a[X]; y3=a[Y]; z3=a[Z]

    a21[X] = x2 - x1
    a21[Y] = y2 - y1
    a21[Z] = z2 - z1

    a31[X] = x3 - x1
    a31[Y] = y3 - y1
    a31[Z] = z3 - z1      
    
    a32[X] = x3 - x2
    a32[Y] = y3 - y2
    a32[Z] = z3 - z2

    cm[X] = 1/3*(x1 + x2 + x3)
    cm[Y] = 1/3*(y1 + y2 + y3)
    cm[Z] = 1/3*(z1 + z2 + z3)
    
    cp(a21, a31, ksi)          # normal vector

    Ak = sqrt(dot(ksi, ksi))/2 # face area 
}

function decode_dih(idi,     a, id1, id2, id3, id4) {
    id1 = d1[idi]; id2 = d2[idi]; id3=d3[idi]; id4=d4[idi]

    split(vert[id1], a)
    x1=a[X]; y1=a[Y]; z1=a[Z]
    
    split(vert[id2], a)
    x2=a[X]; y2=a[Y]; z2=a[Z]

    split(vert[id3], a)
    x3=a[X]; y3=a[Y]; z3=a[Z]

    split(vert[id4], a)
    x4=a[X]; y4=a[Y]; z4=a[Z]

    a21[X] = x2 - x1
    a21[Y] = y2 - y1
    a21[Z] = z2 - z1

    a31[X] = x3 - x1
    a31[Y] = y3 - y1
    a31[Z] = z3 - z1      
    
    a32[X] = x3 - x2
    a32[Y] = y3 - y2
    a32[Z] = z3 - z2

    a24[X] = x2 - x4
    a24[Y] = y2 - y4
    a24[Z] = z2 - z4

    a34[X] = x3 - x4
    a34[Y] = y3 - y4
    a34[Z] = z3 - z4
    
    cm[X] = 1/2*(x1 + x2)
    cm[Y] = 1/2*(y1 + y2)
    cm[Z] = 1/2*(z1 + z2)
    
    cp(a21, a31, ksi) # normal vector to 123 triangel
    cp(a34, a24, sig) # normal vector to 124 triangel

    cos_theta = dot(ksi,sig)/sqrt( dot(ksi,ksi)) / sqrt(dot(sig,sig));
}

function decode_edge(ied,     id1, id2, id3, a) {
    id1 = e1[ied]; id2 = e2[ied]

    split(vert[id1], a)
    x1=a[X]; y1=a[Y]; z1=a[Z]
    
    split(vert[id2], a)
    x2=a[X]; y2=a[Y]; z2=a[Z]

    a21[X] = x2 - x1
    a21[Y] = y2 - y1
    a21[Z] = z2 - z1

    cm[X] = 1/2*(x1 + x2)
    cm[Y] = 1/2*(y1 + y2)
    cm[Z] = 1/2*(z1 + z2)

    l21 = sqrt(dot(a21, a21))
}

function process_edges(    ied) {
    for (ied=1; ied<ned; ied++) {
	decode_edge(ied)
	print cm[X], cm[Y], cm[Z], l21
    }
}

function process_faces(    ifa) {
    for (ifa=1; ifa<nfa; ifa++) {
	decode_face(ifa)
	print cm[X], cm[Y], cm[Z], Ak
    }
}

function process_dihs(    idi) {
    for (idi=1; idi<ndi; idi++) {
	decode_dih(idi)
	print cm[X], cm[Y], cm[Z], cos_theta
    }
}

BEGIN {
    init()
    
    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_header()
    read_vertices()
    read_faces()

    build_edges()
    build_dihs()

    #process_edges()
    # process_faces()
    process_dihs()
}
