#!/usr/bin/awk -f
# refine by splitting every edge into tree

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
    if (d==0) return
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


function abs(x)  { return x<0?x*-1:x;}
function acos(x) { return atan2(sqrt(abs(1-x*x)), x) }

function vabs(A) { return sqrt(dot(A, A)) }
function vsq(A)  { return dot(A, A) }

function dot(A, B,   j, ans) {
    for (j=1; j<=3; j++)
	ans += A[j]*B[j]
    return ans
}

function cp(A, B, C) { # cross product in 3D
    C[1] =   A[2]*B[3] - A[3]*B[2]
    C[2] = -(A[1]*B[3] - A[3]*B[1])
    C[3] =   A[1]*B[2] - A[2]*B[1]
}

function vminus(A, B, C,    j) { # C = A-B
    for (j=1; j<=3; j++)
	C[j] = A[j] - B[j]
}

function trisectEdge(A, B, AB1, AB2,   dp, alp, denom, c1, c2, j) {
    # Trisects the great circle arc joining A and B
    # See rbfsphere matlab package
    # http://math.boisestate.edu/~wright/montestigliano/NodesGridsMeshesOnSphere.pdf
    dp = dot(A, B)
    alp=1/3*acos(dp);
    denom = dp^2 - 1;
    c1 = (dp*cos(2*alp)-cos(alp))/denom;
    c2 = (dp*cos(alp)-cos(2*alp))/denom;

    for (j=1; j<=3; j++) {
	AB1[j] = A[j]*c1 + B[j]*c2
	AB2[j] = B[j]*c1 + A[j]*c2
    }
}

function circumcenterTri2(P1, P2, P3, M,
			 P12, P23, P13,
			 P21, P32, P31,
			 ksi,
			 denom, al, be, ga, j) {
    vminus(P1, P2, P12)
    vminus(P2, P3, P23)
    vminus(P1, P3, P13)

    vminus(P2, P1, P21)
    vminus(P3, P2, P32)
    vminus(P3, P1, P31)

    cp(P12, P23, ksi)
    denom = 2*vsq(ksi)

    al = vsq(P23) * dot(P12, P13) / denom
    be = vsq(P13) * dot(P21, P23) / denom
    ga = vsq(P12) * dot(P31, P32) / denom

    for (j=1; j<=3; j++)
	M[j] = al*P1[j] + be*P2[j] + ga*P3[j]
}

function circumcenterTri(P1, P2, P3, M,    j) {
    for (j=1; j<=3; j++)
	M[j] = (P1[j] + P2[j] + P3[j])/3.0
}


$1 == "def" && $2 == "key" && s($3)==9 {
    split($3, d, SUBSEP)
    print "del key", $3

    i = 0
    A[1] = d[++i]; A[2] = d[++i]; A[3] = d[++i]
    B[1] = d[++i]; B[2] = d[++i]; B[3] = d[++i]
    C[1] = d[++i]; C[2] = d[++i]; C[3] = d[++i]

    trisectEdge(A, B, AB1, AB2)
    trisectEdge(B, C, BC1, BC2)
    trisectEdge(C, A, CA1, CA2)
    circumcenterTri(A, B, C, M)

    # norm
    norm(AB1); norm(AB2); norm(BC1); norm(BC2); norm(CA1); norm(CA2);
    norm(M)

    # def key
    def(AB1); def(AB2); def(BC1); def(BC2); def(CA1); def(CA2); def(M)

    def3(A, AB1, CA2)
    def3(AB2, B, BC1)
    def3(BC2, C, CA1)

    def3(AB1, M, CA2)
    def3(BC1, M, AB2)
    def3(CA1, M, BC2)

    def3(AB1, AB2, M)
    def3(BC1, BC2, M)
    def3(CA1, CA2, M)
	
    next
}

{
    print
}
