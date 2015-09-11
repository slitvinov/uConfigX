#!/usr/bin/awk -f

function rescale(key,    line, aux, i, k, nn, xr, yr, zr) {
    nn = split(key, aux, SUBSEP)
    while (1) {
	if (i>=nn) break
	x = aux[++i]; y = aux[++i]; z = aux[++i]
	xr = 2
*x; yr = 2*y; zr = z_rbc(xr, yr, z)
	sep = line ? SUBSEP : ""
	line = line sep xr SUBSEP yr SUBSEP zr
    }
    return line
}


function z_rbc(x, y, z,    ans, D0, a0, a1, a2) {
    D0 = 7.82
    a0 = 0.0518
    a1=2.0026
    a2=-4.491
    ans = D0 * sqrt(1 - 4*(x^2 + y^2)/D0^2) * \
           (a0 + a1 * (x^2 + y^2)/D0^2 + a2*(x^2 + y^2)^2/D0^4)
    return z>0 ? ans : -ans
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
