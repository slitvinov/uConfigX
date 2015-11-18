#!/usr/bin/awk -f
# Create tetrahedron
# https://en.wikipedia.org/wiki/Tetrahedron
# Usage:
# ./tetrahedron.awk
#
# TEST: tet1
# awk -f tetrahedron.awk  > tet.out.trdf
#
# TEST: tet2
# awk -f tetrahedron.awk  | ur clean.awk | ur unref.awk | ur unref2vtk.awk > tet.out.vtk


function tri(id1, id2, id3) {
    printf "\n"
    printf "plg [n 3]\n"
    printf "ref [id %d]\n", id1
    printf "ref [id %d]\n", id2
    printf "ref [id %d]\n", id3
}

function point(xs, ys, zs, id,    d) {
    d = sqrt(xs^2 + ys^2 + zs^2)
    x = xs/d; y = ys/d; z = zs/d
    
    printf "def [id %d] [pos %.12g %.12g %.12g]\n", id, x, y, z
}

BEGIN {
    OFMT="%.12g"

    point(-1, -1, -1, ++id)
    point(1,  1, -1,  ++id)
    point(1, -1,  1,  ++id)
    point(-1,  1,  1, ++id)
    point(-1, -1, -1, ++id)

    tri(2, 3, 4)
    tri(2, 1, 3)
    tri(4, 3, 1)
    tri(1, 2, 4)
}
