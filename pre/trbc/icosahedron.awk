#!/usr/bin/awk -f

function tri(id1, id2, id3) {
    printf "\n"
    printf "plg [n 3]\n"
    printf "ref [id %d]\n", id1
    printf "ref [id %d]\n", id2
    printf "ref [id %d]\n", id3
}

function point(x, y, z, id,    d) {
    d = sqrt(x^2 + y^2 + z^2)
    x /= d; y /= d; z /= d
    printf "def [id %d] [pos %g %g %g]\n", id, x, y, z
}

BEGIN {

    t = (1.0 + sqrt(5.0)) / 2.0
    
    point(-1,  t,  0, id++)

    point( 1,  t,  0, id++)
    point(-1, -t,  0, id++)
    point( 1, -t,  0, id++)

    point(0, -1,  t, id++)
    point(0,  1,  t, id++)
    point(0, -1, -t, id++)
    point(0,  1, -t, id++)

    point(t,  0, -1, id++)
    point(t,  0,  1, id++)
    point(-t,  0, -1, id++)
    point(-t,  0,  1, id++)

    tri(0, 11, 5)
    tri(0, 5, 1)
    tri(0, 1, 7)
    tri(0, 7, 10)
    tri(0, 10, 11)

    tri(1, 5, 9)
    tri(5, 11, 4)
    tri(11, 10, 2)
    tri(10, 7, 6)
    tri(7, 1, 8)

    tri(3, 9, 4)
    tri(3, 4, 2)
    tri(3, 2, 6)
    tri(3, 6, 8)
    tri(3, 8, 9)

    tri(4, 9, 5)
    tri(2, 4, 11)
    tri(6, 2, 10)
    tri(8, 6, 7)
    tri(9, 8, 1)
    
}
