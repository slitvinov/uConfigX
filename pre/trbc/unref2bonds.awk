#!/usr/bin/awk -f

# force numeric
function fn(x) {
    return x+0
}

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

function nvert(      n, key) {
    for (key in keys)
	if (s(key)==3) n++
    return n
}

END {
    printf "# vtk DataFile Version 2.0\n"
    printf "Generated with unref2vtk.awk\n"
    printf "ASCII\n"
    printf "DATASET POLYDATA\n"
    
    # find bonds
    polygon_block = ""
    for (key in keys) {
	if (s(key)==6) {
	    n_bonds++
	    decode(key)
	    xc = 2/3.0*x2 + 1/3.0*x1
	    yc = 2/3.0*y2 + 1/3.0*y1
	    zc = 2/3.0*z2 + 1/3.0*z1
#	    xc = x2; yc = y2; zc = z2
	    sep = polygon_block ? "\n" : ""
	    polygon_block = polygon_block sep xc " " yc " " zc
	}
    }

    printf "POINTS %d float\n", n_bonds
    print  polygon_block

    printf "VERTICES %d %d\n", 1, n_bonds + 1
    printf "%d\n", n_bonds
    for (m=1; m<=n_bonds; m++)
	printf "%d\n", m
    
    # printf "\n"
    # printf "POLYGONS %d %d\n", ntri, 4*ntri
    # print polygon_block
}
