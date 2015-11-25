#!/usr/bin/awk -f
# Create icosahedron
# https://en.wikipedia.org/wiki/Regular_icosahedron
# Usage:
# awk -f icosahedron.awk
#
# TEST: ico1
# awk -f icosahedron.awk  > ico.out.trdf

function tri(id1, id2, id3) {
    printf "\n"
    printf "plg [n 3]\n"
    printf "ref [id %d]\n", id1
    printf "ref [id %d]\n", id2
    printf "ref [id %d]\n", id3

    if (edg) {
	edge(id1, id2)
	edge(id1, id3)
	edge(id2, id3)
    }
}

function add_edge_hash(id1, id2) {
    eh[id1,id2]=1
    eh[id2,id1]=1
}

function in_edge_hash(id1, id2) {
    return ( (id1, id2) in eh )
}

function edge(id1, id2) {
    if (in_edge_hash(id1, id2)) return
    printf "\n"
    printf "plg [n 2]\n"
    printf "ref [id %d]\n", id1
    printf "ref [id %d]\n", id2
    add_edge_hash(id1, id2)
}

function point(xs, ys, zs, id,    d) {
    d = sqrt(xs^2 + ys^2 + zs^2)
    x = xs/d; y = ys/d; z = zs/d
    
    printf "def [id %d] [pos %.12g %.12g %.12g]\n", id, x, y, z
}

BEGIN {
    OFMT="%.12g"

    # golden ration
    p = (1.0 + sqrt(5.0))/2.0

    point(0, p, 1, ++id)
    point(0, -p, 1, ++id)
    point(0, p, -1, ++id)
    point(0, -p, -1, ++id)
    point(1, 0, p, ++id)
    point(-1, 0, p, ++id)
    point(1, 0, -p, ++id)
    point(-1, 0, -p, ++id)
    point(p, 1, 0, ++id)
    point(-p, 1, 0, ++id)
    point(p, -1, 0, ++id)
    point(-p, -1, 0, ++id)
    
    tri(     10,     6,     1)
    tri(     3,    10,     1)
    tri(    11,     5,     2)
    tri(    12,     6,    10)
    tri(     8,    12,    10)
    tri(     4,    12,     8)
    tri(     8,    10,     3)
    tri(     5,     1,     6)
    tri(     5,     6,     2)
    tri(     3,     1,     9)
    tri(     5,     9,     1)
    tri(    11,     9,     5)
    tri(    12,     4,     2)
    tri(     6,    12,     2)
    tri(     8,     3,     7)
    tri(     8,     7,     4)
    tri(    11,     4,     7)
    tri(    11,     2,     4)
    tri(     7,     9,    11)
    tri(     3,     9,     7)
}
