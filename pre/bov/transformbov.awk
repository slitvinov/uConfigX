#!/usr/bin/awk -f
#
# Geometrical transform of BOV [1] file. Currently only simple scaling
# by factor `sc' is supported
#
# Refs:
# [1] https://wci.llnl.gov/codes/visit/2.0.0/GettingDataIntoVisIt2.0.0.pdf

# Usage:
# ./transformbov.awk <input bov> <output bov> <sc>

function strip_comments() {sub(/#.*/, "")}
function strip_tr_ws(s)   {  # strip trailing whitespaces
    sub(/^[ \t]*/, "", s)
    sub(/[ \t]*$/, "", s)
    return s
}

function parse_line(s)     { # sets `lhs' and `rhs'
    match(s, /^[^:]+:/)
    lhs = substr(s, RSTART, RLENGTH-1)
    lhs = strip_tr_ws(lhs)

    rhs = substr(s, RSTART+RLENGTH)
    rhs = strip_tr_ws(rhs)
}

function emptyp(s) {return s ~ /^[\t ]*$/}

function parse_data_size(s,    arr) {
    split(s, arr)
    nLx=arr[1]; nLy=arr[2]; nLz=arr[3]
}

function parse_brick_origin(s,    arr) {
    split(s, arr)
    xl=arr[1]; yl=arr[2]; zl=arr[3]
}

function parse_brick_size(s,    arr) {
    split(s, arr)
    Lx=arr[1]; Ly=arr[2]; Lz=arr[3]
}

function parse_bov(fi     ) {
    while (getline < fi > 0) {
	strip_comments()
	if (emptyp($0)) continue
	parse_line($0) # sets `lhs' and `rhs'
	if      (lhs=="DATA_FILE") df = rhs # data file
	else if (lhs=="DATA SIZE")    parse_data_size(rhs)
	else if (lhs=="BRICK ORIGIN") parse_brick_origin(rhs)
	else if (lhs=="BRICK SIZE")   parse_brick_size(rhs)
    }
    close(fi)
}

function output_bov(fi, fo,    oline) {
    while (getline < fi > 0) {
	oline = $0
	strip_comments()
	if (emptyp($0)) {
	    print oline > fo
	    continue
	}
	parse_line($0) # sets `lhs' and `rhs'
	if      (lhs=="DATA_FILE")
	    print lhs ":", odf > fo # ouptut data file
	else if (lhs=="BRICK ORIGIN")
	    print lhs ":", xl, yl, zl > fo
	else if (lhs=="BRICK SIZE")
	    print lhs ":", Lx, Ly, Lz > fo
	else
	    print oline > fo
    }
    close(fi)
}

function abs(x) {return x>0 ? x : -x}

function transform_bov(   dx, dy, dz, asc) {
    asc = abs(sc)
    xl = asc*xl; yl = asc*yl; zl = asc*zl
    Lx = asc*Lx; Ly = asc*Ly; Lz = asc*Lz             # "BRICK SIZE"
}

function transform_values(    odf_full, d, cmd) {
    cmd = sprintf("dirname \"%s\"", fi)
    cmd | getline d

     df_full = d "/"  df
    odf_full = d "/" odf

    cmd = sprintf(\
	"%s %s  %s  %d    %d   %d    %g",
	TRANSFORMBOV_EXE, df_full, odf_full,\
	            nLx, nLy, nLz,   sc)
    lsystem(cmd)
}

function lsystem(cmd, rc) {
    printf "(transformbov.awk) executing:\n%s\n", cmd
    rc = system(cmd)
    if (rc) {
	printf "(transformbov.awk)(ERROR)\n"
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

BEGIN {
    TRANSFORMBOV_EXE="ur transformbov" # shell command to transform values
    
    fi=ARGV[1] # input BOV
    fo=ARGV[2] # output BOV

    sc=ARGV[3]

    parse_bov(fi)
    odf = repsuffix(basename(fo), "bov", "values")

    transform_values()
    transform_bov()

    output_bov(fi, fo)
    exit
}
