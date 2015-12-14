#!/usr/bin/awk -f
#
# Splice BOV [1] file. Create a new BOV file with the following
# content
# data[sxl:shx][syl:syh][szl:szh]
# DATA SIZE : <sxh-slx> <syh-syl> <szh-szl>
# BRICK ORIGIN: <see the source code>
# BRICK SIZE  : <see the source code>

# Refs:
# [1] https://wci.llnl.gov/codes/visit/2.0.0/GettingDataIntoVisIt2.0.0.pdf

# Usage:
# ./nslicebov.awk <input bov> <output bov> <sxl> <syl> <szl>    <sxh> <syh> <szh>
#
# TEST: nslicebov1
# ur nslicebov.awk -v debug=1 test_data/ex1.bov slice.bov 0 0 0    1 1 1
# mv slice.bov slice.out.bov
#
# TEST: nslicebov2
# ur nslicebov.awk -v debug=1 test_data/ex1.bov slice.bov 1 1 1    2 2 2
# mv slice.bov slice.out.bov
#
# TEST: nslicebov3
# ur nslicebov.awk -v debug=1 test_data/ex1.bov slice.bov 3 3 3    4 4 4
# mv slice.bov slice.out.bov
#
# TEST: nslicebov4
# ur nslicebov.awk -v debug=1 test_data/ex2.bov slice.bov -10 -10 -10   10 10 10
# mv slice.bov slice.out.bov
#
# TEST: nslicebov5
# ur nslicebov.awk -v debug=1 test_data/ex2.bov slice.bov 0 0 0   1 1 1
# mv slice.bov slice.out.bov
#
<<<<<<< HEAD
# TEST: nslicebov6
# ur nslicebov.awk -v debug=1 test_data/b1.bov slice.bov 1 1 1   72 48 24
# mv slice.bov slice.out.bov
#

=======
>>>>>>> 881fa78db8ea1ffb69f318c7a69ec1ab1d17d372

function min(a, b) {return a < b ? a : b}
function max(a, b) {return a > b ? a : b}

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
	else if (lhs=="DATA SIZE") parse_data_size(rhs)
	else if (lhs=="BRICK ORIGIN") parse_brick_origin(rhs)
	else if (lhs=="BRICK SIZE") parse_brick_size(rhs)
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
	else if (lhs=="DATA SIZE")
	    print lhs ":", nLx, nLy, nLz > fo
	else if (lhs=="BRICK ORIGIN")
	    print lhs ":", xl, yl, zl > fo
	else if (lhs=="BRICK SIZE")
	    print lhs ":", Lx, Ly, Lz > fo
	else
	    print oline > fo
    }
    close(fi)
}

function splice_bov(   dx, dy, dz) {
    dx = Lx/(nLx-1); dy = Ly/(nLy-1); dz = Lz/(nLz-1)

    nLx = sxh - sxl + 1; nLy = syh - syl + 1; nLz = szh - szl  + 1
                                                      # "DATA SIZE"
                                                      # TODO: should
                                                      # it be round?

    xl +=  sxl*dx; yl +=  syl*dy; zl +=  szl*dz       # "BRICK ORIGIN"
    Lx = (nLx-1)*dx; Ly = (nLy-1)*dy; Lz = (nLz-1)*dz # "BRICK SIZE"
}

function splice_values(    odf_full, d_in, d_out, cmd) { # slice value file
    d_in  = dirname(fi)
    d_out = dirname(fo)

     df_full = d_in  "/"  df
    odf_full = d_out "/" odf

    cmd = sprintf(\
	"%s  %s %s      %d    %d   %d    %d    %d   %d      %d   %d  %d",
	NSLICEBOV_EXE, df_full, odf_full,             nLx, nLy, nLz,   sxl, syl, szl,    sxh, syh, szh)

    if (!debug)
	lsystem(cmd)
    else {
	printf "(nslicebov.awk)(DEBUG): \n"
	printf "%s\n", cmd
    }
}

function lsystem(cmd, rc) {
    printf "(nslicebov.awk) executing:\n%s\n", cmd
    rc = system(cmd)
    if (rc) {
	printf "(nslicebov.awk)(ERROR)\n"
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

function bond_limits() { # bond for `s[xyz][lh]'
    sxl = max(sxl, 0); syl = max(syl, 0); szl = max(szl, 0)
    sxh = min(sxh, nLx-1); syh = min(syh, nLy-1); szh = min(szh, nLz-1);
}

BEGIN {
    NSLICEBOV_EXE="ur nslicebov" # shell command to transform values

    fi=ARGV[1] # input BOV
    fo=ARGV[2] # output BOV

    sxl=ARGV[3]; syl=ARGV[4]; szl=ARGV[5]
    sxh=ARGV[6]; syh=ARGV[7]; szh=ARGV[8]

    parse_bov(fi)
    bond_limits()
<<<<<<< HEAD
    odf = repsufix(basename(fo), "bov", "values")
=======
    odf = repsuffix(basename(fo), "bov", "values")
>>>>>>> 881fa78db8ea1ffb69f318c7a69ec1ab1d17d372

    splice_values()
    splice_bov()

    output_bov(fi, fo)
    exit
}
