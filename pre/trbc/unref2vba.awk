#!/usr/bin/awk -f

# "unref" to vertices, bonds and angles

# force numeric
function fn(x) {
    return x+0
}

function decode(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    x1 = aux[++i]; y1 = aux[++i]; z1 = aux[++i];
    x2 = aux[++i]; y2 = aux[++i]; z2 = aux[++i];
    x3 = aux[++i]; y3 = aux[++i]; z3 = aux[++i];    
}

function s(key,   nn, aux) {
    nn = split(key, aux, SUBSEP)
    return nn
}

function xyz2key(x, y, z) {
    return x SUBSEP y SUBSEP z
}

function bond(r1, r2) {
    return r1>r2 ? (r1 SUBSEP r2) : (r2 SUBSEP r1)
}

$1 == "def" && $2 == "key" {
    key = $3
    keys[$3]++
}

$1 == "del" && $2 == "key" {
    key = $3
    delete keys[key]
}

END {
    for (key in keys) {
	if (s(key)==9) {
	    decode(key)
	    r1 = xyz2key(x1, y1, z1)
	    r2 = xyz2key(x2, y2, z2)
	    r3 = xyz2key(x3, y3, z3)	    
	    print "def key", r1
	    print "def key", r2
	    print "def key", r3

	    print "def key", bond(r1, r2)
	    print "def key", bond(r2, r3)
	    print "def key", bond(r3, r1)

	    print "def key", r1 SUBSEP r2 SUBSEP r3
	}
    }
}

    
