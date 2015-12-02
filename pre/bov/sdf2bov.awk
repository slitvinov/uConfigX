#!/usr/bin/awk -f

# Convert sdf to BOV format
# Usage:
# ./sdf2bov <input sdf file> <output bov file>

# TEST: sdf2bov1
# ur sdf2bov.awk test_data/egg.sdf.dat egg.bov
# md5sum                               egg.values >> egg.bov
# cp egg.bov           sdf2bov.out.bov
# rm egg.bov egg.values ## clean up

function lsystem(cmd,    rc) {
    printf "(sdf2bov) executing:\n%s\n", cmd > "/dev/stderr"
    rc = system(cmd)
    if (rc) {
	printf "(sdf2bov)(ERROR)\n" > "/dev/stderr"
	exit rc
    }
}

function str2reg(s,   arr, nn, i, ans) { # abc -> [a][b][c]
    nn = split(s, arr, "")
    for (i=1; i<=nn; i++)
	ans = ans "[" arr[i] "]"
    return ans
}

function repsuffix(s, s1, s2,   r1) {
    r1 = "[.]" str2reg(s1) "$"
    sub(r1, "." s2, s)
    return s
}

function basename(s,    cmd, b) {
    cmd = sprintf("basename \"%s\"", s)
    cmd | getline b
    return b
}

function dirname(s,    cmd, d) {
    cmd = sprintf("dirname \"%s\"", s)
    cmd | getline d
    return d
}

function read_sdf_header() {
    getline < fi
    xl = 0 ; yl = 0 ; xl = 0
    xh = $1; yh = $2; zh = $3
    Lx = xh - xl ; Ly = yh - yl; Lz = zh - zl

    getline < fi
    nx = $1; ny = $2; nz = $3

    close(fi)
}

function print_bov_header() {
    printf "#BOV version: 1.0\n"       > fo
    printf "#Created by sdf2bov.awk\n" > fo
}

function print_bov_fixed() {
    printf "DATA FORMAT: FLOATS\n" > fo
    printf "VARIABLE: \"wall\"\n"  > fo
}

function print_bov_var() {
    printf "DATA SIZE: %d %d %d\n", nx, ny, nz > fo

    printf "BRICK ORIGIN: %g %g %g\n", xl, yl, zl > fo
    printf "BRICK SIZE:   %g %g %g\n", Lx, Ly, Lz > fo

    printf "DATA_FILE: %s\n", odf                 > fo
}

function create_values(    d_out, odf_full) { # copy all but first two lines to data file
    d_out = dirname(fo)
    odf_full = d_out "/" odf

    cmd = sprintf("tail -n +3 \"%s\"    >    \"%s\"", fi, odf_full)
    lsystem(cmd)
}

BEGIN {
    fi = ARGV[1]
    fo = ARGV[2]

    odf = repsuffix(basename(fo), "bov", "values") # a name of output
						   # data file
    read_sdf_header()

    print_bov_header()
    print_bov_fixed()
    print_bov_var()

    create_values()

    exit
}
