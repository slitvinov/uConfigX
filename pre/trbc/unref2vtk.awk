#!/usr/bin/awk -f

# force numeric
function fn(x) {
    return x+0
}

function decode(key,   sep, aux, ans, nn, i, k) {
    LINE = ""
    nn = split(key, aux, SUBSEP)
    while (1) {
	if (i>=nn) break
	k = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]
	if (!(k in keys))
	    return 0
	else {
	    sep = LINE ? " " : ""
	    LINE = LINE sep key2id[k]
	}
    }
    return 1
}

function s(key,   nn, aux) {
    nn = split(key, aux, SUBSEP)
    return nn
}

function key2xyz(key, aux) {
    split(key, aux, SUBSEP)
    x = aux[1]; y = aux[2]; z = aux[3]
}

$1 == "def" && $2 == "key" {
    key = $3
    keys[$3]++
}

$1 == "del" && $2 == "key" {
    key = $3
    delete keys[key]
}

function nvert(      n) {
    for (key in keys)
	if (s(key)==3) n++
    return n
}

END {
    printf "# vtk DataFile Version 2.0\n"
    printf "Generated with unref2vtk.awk\n"
    printf "ASCII\n"
    printf "DATASET POLYDATA\n"

    nv = nvert()
    printf "POINTS %d float\n", nv
    # asign ids to points
    for (key in keys)
	if (s(key)==3) {
	    key2xyz(key)
	    key2id[key] = fn(id++)
	}

    # print points
    for (key in keys)
	if (s(key)==3) {
	    key2xyz(key)
	    print x, y, z
	}

    # print triangles
    polygon_block = ""
    for (key in keys) {
	if (s(key)==9) {
	    rc = decode(key)
	    if (rc) {
		ntri ++
		sep = polygon_block ? "\n" : ""
		polygon_block = polygon_block sep "3 " LINE
	    }
	}
    }
    printf "\n"
    printf "POLYGONS %d %d\n", ntri, 4*ntri
    print polygon_block
}
