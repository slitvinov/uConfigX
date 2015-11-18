#!/usr/bin/awk -f

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

END {
    printf "# vtk DataFile Version 2.0\n"
    printf "Generated with unref2norm.awk\n"
    printf "ASCII\n"
    printf "DATASET POLYDATA\n"
    
    # find bonds
    polygon_block = ""
    for (key in keys) {
	if (s(key)==9) {
	    n_bonds++
	    decode(key)
	    xc = 1/3.0*(x1 + x2 + x3)
	    yc = 1/3.0*(y1 + y2 + y3)
	    zc = 1/3.0*(z1 + z2 + z3)

	    x31 = x3 - x1; y31 = y3 - y1; z31 = z3 - z1
	    x21 = x2 - x1; y21 = y2 - y1; z21 = z2 - z1

	    xksi =   y21*z31 - z21*y31
	    yksi = -(x21*z31 - z21*x31)
	    zksi =   x21*y31 - y21*x31
	    dot_ksi = xksi^2 + yksi^2 + zksi^2
	    xn = xc + k*xksi; yn = yc + k*yksi; zn = zc + k*zksi
	    
	    sep = polygon_block ? "\n" : ""
	    polygon_block = polygon_block sep xc " " yc " " zc

	    sep = "\n"
	    polygon_block = polygon_block sep xn " " yn " " zn
	}
    }

    printf "POINTS %d float\n", 2*n_bonds
    print  polygon_block

    printf "LINES %d %d\n", n_bonds, 3*n_bonds
    for (m=0; m<n_bonds; m++)
	printf "%d %d %d\n", 2, 2*m, 2*m+1
    
    # printf "\n"
    # printf "POLYGONS %d %d\n", ntri, 4*ntri
    # print polygon_block
}
