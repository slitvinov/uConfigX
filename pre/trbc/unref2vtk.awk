#!/usr/bin/awk -f

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
    nv = nvert()
    printf "DATASET UNSTRUCTURED_GRID\n"
    printf "POINTS %d float\n", nv

    for (key in keys)
	if (s(key)==3) {
	    key2xyz(key)
	    print x, y, z
	}
}
