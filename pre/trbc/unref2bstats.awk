#!/usr/bin/awk -f

function decode(key,   sep, aux, nn, i) {
    nn = split(key, aux, SUBSEP)
    x1 = aux[++i]; y1 = aux[++i]; z1 = aux[++i];
    x2 = aux[++i]; y2 = aux[++i]; z2 = aux[++i];
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
    polygon_block = ""
    for (key in keys) {
	if (s(key)==6) { # bond
	    decode(key)

	    dx = x1 - x2
	    dy = y1 - y2
	    dz = z1 - z2

	    # normal vector, cross_product(x21,x31)
	    xksi =   y21*z31 - z21*y31
	    yksi = -(x21*z31 - z21*x31)
	    zksi =   x21*y31 - y21*x31

	    print sqrt(dx^2+dy^2+dz^2)
	}
    }

}
