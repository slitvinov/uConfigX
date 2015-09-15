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

BEGIN {
    OFMT="%.12g"
}

function def(kk) {
    print "def key " k(kk)
}

function def3(k1, k2, k3) {
    print "def key " k(k1)  SUBSEP k(k2) SUBSEP k(k3)
}

$1 == "def" && $2 == "key" && s($3)==9 {
    split($3, d, SUBSEP)
    i = 0
    A[1] = d[++i]; A[2] = d[++i]; A[3] = d[++i]
    B[1] = d[++i]; B[2] = d[++i]; B[3] = d[++i]
    C[1] = d[++i]; C[2] = d[++i]; C[3] = d[++i]

    for (j=1; j<=3; j++) {
	AB1[j] = 1/3.0 * ( 2*A[j] + 1*B[j])
	AB2[j] = 1/3.0 * ( 1*A[j] + 2*B[j])
	BC1[j] = 1/3.0 * ( 2*B[j] + 1*C[j])
	BC2[j] = 1/3.0 * ( 1*B[j] + 2*C[j])
	CA1[j] = 1/3.0 * ( 2*C[j] + 1*A[j])
	CA2[j] = 1/3.0 * ( 1*C[j] + 2*A[j])
	
	M[j]   = 1/3.0 * (A[j] + B[j] + C[j])
    }

    print "del key", $3

    # norm
    norm(AB1); norm(AB2); norm(BC1); norm(BC2); norm(CA1); norm(CA2); norm(M)
    # def key
    def(AB1); def(AB2); def(BC1); def(BC2); def(CA1); def(CA2); def(M)

    def3(A, AB1, CA2)
    def3(AB2, B, BC1)
    def3(BC2, C, CA1)

    def3(AB1, M, CA2)
    def3(AB2, M, BC1)
    def3(BC2, M, CA1)

    def3(AB1, AB2, M)
    def3(BC1, BC2, M)
    def3(CA1, CA2, M)
	
    next
}

{
    print
}
