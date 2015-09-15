#!/usr/bin/awk -f

# force numeric
function fn(x) { return x + 0.0}

function rescale(key,    line, aux, i, k, nn, x, y, z) {
    nn = split(key, aux, SUBSEP)
    while (1) {
	if (i>=nn) break
	x = aux[++i]; y = aux[++i]; z = aux[++i]
	rbc(x, y, z)
	sep = line ? SUBSEP : ""
	line = line sep fn(xr) SUBSEP fn(yr) SUBSEP fn(zr)
    }
    return line
}

function safe_sqrt(x) {
    if (x<0) x = 0
    return sqrt(x)
}

# sets xr, yr, zr
function rbc(x, y, z,    ans, rho, D0, R0, a0, a1, a2) {
    D0 = 7.82
    R0 = D0 / 2.0
    a0 = 0.0518
    a1 = 2.0026
    a2 = -4.491

    xr = x*R0
    yr = y*R0
    rho  = sqrt(xr^2 + yr^2)
    ans = D0 * safe_sqrt(1 - 4*rho^2/D0^2) * \
           (a0 + a1 * rho^2/D0^2 + a2*rho^4/D0^4)

    zr = z>0 ? ans : -ans
}

function s(key,   nn, aux) {
    nn = split(key, aux, SUBSEP)
    return nn
}

$1 == "def" && $2 == "key" {
    key = $3
    
    key = rescale(key)
    print "def key " key

    next
}

{
    print
}
