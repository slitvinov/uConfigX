#!/usr/bin/awk -f
# Example:
# ./placeunref.awk examples/rbc1-ic.txt examples/rbc.org.unref    | ./unref2vtk.awk > v.vtk

BEGIN {
    ic = ARGV[1] # initial conditions file
    ARGV[1] = ""
}

NF {
    templ[++nl]=$0
}

function next_matrix(M,    i, j) {
    next_element(); next_element(); next_element() # ignore first threee elements
    for (i=1; i<=4; i++)
	for (j=1; j<=4; j++)
	    M[i, j] = next_element()
}

function rev(a, n,    i, j, to, tmp) { # reverse array
    for (i=1; (j=n-i+1) > i ; i++) {
	tmp = a[i]; a[i] = a[j]; a[j] = tmp
    }
}

function next_element() {
    while (in_bufer == 0) {
	if ((getline < ic) <= 0)
	    exit
	in_bufer = split($0, buf)
	rev(buf, in_bufer)
    }
    
    return buf[in_bufer--]
}

END {
    for (;;) {
	next_matrix(M)
	print_cell()
    }
}

function print_cell(   i) {
    for (i=1; i<=nl; i++)
	process_line(templ[i])
}

function update_xyz() {
    x = M[1,3]*z0+M[1,2]*y0+M[1,1]*x0+M[1,4]
    y = M[2,3]*z0+M[2,2]*y0+M[2,1]*x0+M[2,4]
    z = M[3,3]*z0+M[3,2]*y0+M[3,1]*x0+M[3,4]    
}

function process_line(line,    sep, arr, nn, i) {
    sub("^def key ", "", line)
    nn = split(line, arr, SUBSEP)

    printf "def key "
    while (i<nn) {
	x0=arr[++i]
	y0=arr[++i]
	z0=arr[++i]
	update_xyz()
	printf sep x SUBSEP y SUBSEP z
	sep = SUBSEP
    }
    printf "\n"
}
