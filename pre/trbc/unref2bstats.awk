#!/usr/bin/awk -f

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

function decode(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    x1 = aux[++i]; y1 = aux[++i]; z1 = aux[++i];
    x2 = aux[++i]; y2 = aux[++i]; z2 = aux[++i];
}

# calculate a length of a bond
function lbond(key,  r1, r2, r21) {
    decode(key)

    r1[1] = x1; r1[2] = y1; r1[3] = z1
    r2[1] = x2; r2[2] = y2; r2[3] = z2
    
    vminus(r2, r1, r21)
    
    return  vabs(r21)
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

END {
    for (key in keys)
	if (s(key)==6)
	    print lbond(key)
}
