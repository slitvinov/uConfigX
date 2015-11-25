#!/usr/bin/awk -f
# double the objects in gts file
#
# Usage:
# ./dgts.awk icosa.gts
#
# Refs:
# http://gts.sourceforge.net/reference/gts-surfaces.html#GTS-SURFACE-WRITE
# http://gts.sourceforge.net/samples.html

BEGIN {
    xs = 5; ys = 0; zs = 0 # how to shift the second object

    fn = ARGV[1]
    ARGV[1] = ""

    getline < fn
    nv = $1; ne = $2; nf = $3 #  number of vertices, number of edges,
			      #  number of faces
    print 2*nv, 2*ne, 2*nf

    # double vertices
    for (iv=1; iv<=nv; iv++) {
	getline < fn
	x = $1; y = $2; z = $3
	vert[   iv]    = x      " " y      " " z
	vert[nv+iv]    = x + xs " " y + ys " " z + zs
    }
    for (iv=1; iv<=2*nv; iv++)
	print vert[iv]

    # double edges
    for (ie=1; ie<=ne; ie++) {
	getline < fn
	id1 = $1; id2 = $2
	print id1, id2	
	edge[ie] = id1 + nv " " id2 + nv
    }
    for (ie=1; ie<=ne; ie++)
	print edge[ie]

    # double faces
    for (ifa=1; ifa<=nf; ifa++) {
	getline < fn
	id1 = $1; id2 = $2; id3 = $3
	print id1, id2, id3
	face[ifa] = id1 + ne " " id2 + ne " " id3 + ne
    }
    for (ifa=1; ifa<=nf; ifa++)
	print face[ifa]
}

