#!/usr/bin/awk -f

function s(key,   nn, aux) {
    nn = split(key, aux, SUBSEP)
    return nn
}

function k(v,    i, sep, ans) {
    for (i=1; i<=length(v); i++) {
	sep = ans ? SUBSEP : ""
	ans = ans sep v[i]
    }
    return ans
}

function norm(v,    i, d2, d) {
    for (i=1; i<=length(v); i++)
	d2 += v[i]^2
    if (d2==0) return
    d = sqrt(d2)
    for (i=1; i<=length(v); i++)
	v[i] /= d
}

$1 == "def" && $2 == "key" && s($3)==9 {
    split($3, d, SUBSEP)
    i = 0
    v1[1] = d[++i]; v1[2] = d[++i]; v1[3] = d[++i]
    v2[1] = d[++i]; v2[2] = d[++i]; v2[3] = d[++i]
    v3[1] = d[++i]; v3[2] = d[++i]; v3[3] = d[++i]

    for (j=1; j<=3; j++) {
	v12[j] = 0.5*(v1[j] + v2[j])
	v13[j] = 0.5*(v1[j] + v3[j])
	v23[j] = 0.5*(v2[j] + v3[j])
    }

    norm(v12); norm(v23); norm(v13)

    print "del key", $3
    
    print "def key " k(v12)
    print "def key " k(v23)
    print "def key " k(v13)
    
    print "def key " k(v1)  SUBSEP k(v12) SUBSEP k(v13)
    print "def key " k(v12) SUBSEP k(v2)  SUBSEP k(v23)
    print "def key " k(v13) SUBSEP k(v23)  SUBSEP k(v3)
    print "def key " k(v12) SUBSEP k(v13)  SUBSEP k(v23)
    next
}

{
    print
}
