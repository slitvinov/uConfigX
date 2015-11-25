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

function nvert(      n, key) {
    for (key in keys)
	if (s(key)==3) n++
    return n
}

function nedge(      n, key) {
    for (key in keys)
	if (s(key)==6) n++
    return n
}

function ntri(      n, key) {
    for (key in keys)
	if (s(key)==9) n++
    return n
}

END {
    nv = nvert()
    ne = nedge()
    nt = ntri()
    
    print nv, ne, nt
    
    # asign ids to points
    for (key in keys)
	if (s(key)==3) {
	    key2xyz(key)
	    key2id[key] = fn(++id) # start from 1 for 
	}

    # print points
    for (key in keys)
	if (s(key)==3) {
	    key2xyz(key)
	    print x, y, z
	}

    # print edges
    for (key in keys) {
	if (s(key)==6) {
	    rc = decode(key)
	    if (rc)
		print LINE
	}
    }

    # print triangles
    for (key in keys) {
	if (s(key)==9) {
	    rc = decode(key)
	    if (rc)
		print LINE
	}
    }
}
