#!/usr/bin/awk -f
# Convert "unref" file to uDevice input format

BEGIN {
    # scale the geometry by this factor
    sc = length(sc) ? sc : 1.0
}

# force numeric
function fn(x) {
    return x+0
}

function decode1(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    x = aux[++i]; y = aux[++i]; z = aux[++i]
}

function decode2(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    k1 = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]
    k2 = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]    
}

function decode3(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    k1 = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]
    k2 = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]
    k3 = aux[++i] SUBSEP aux[++i] SUBSEP aux[++i]
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

function nvert(      n, key) {
    for (key in keys)
	if (s(key)==3) n++
    return n
}

function nbonds(     n, key) {
    for (key in keys)
	if (s(key)==6) n++
    return n
}

function nang(      n, key) {
    for (key in keys)
	if (s(key)==9) n++
    return n
}

function vert2id(    key, id) {
    for (key in keys)
	if (s(key)==3 && !(key in key2id)) {
	    id2key[++id] = key
	    key2id[key]  = id
	}
}

END {
    nv = nvert()
    print nv
    print nbonds()
    print nang()

    # the number of dihedrals
    ndih =  nbonds()
    print ndih

    vert2id()
    printf "\n"
    printf "Atoms\n"
    printf "\n"    
    for (i = 1; i<=nv; i++) {
	key = id2key[i]
	decode1(key)
	print i, 1, 1, sc*x, sc*y, sc*z
    }
    
    printf "\n"
    printf "Bonds\n"
    printf "\n"
    for (key in keys)
	if (s(key)==6) {
	    decode2(key)
	    id1 = key2id[k1]
	    id2 = key2id[k2]
	    print ++ib, 1, id1, id2
	}

    printf "\n"
    printf "Angles\n"
    printf "\n"
    for (key in keys)
	if (s(key)==9) {
	    decode3(key)
	    id1 = key2id[k1]
	    id2 = key2id[k2]
	    id3 = key2id[k3]	    
	    print ++ia, 1, id1-1, id2-1, id3-1
	}
    
}
