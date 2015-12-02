#!/usr/bin/awk -f

# Set dimensions of BOV file (inplace). Updates
#
# Usage:
# ./set_box_bov.awk <bov>  sxl> <yl> <zl>    <xh> <yh> <zh>
#
# TEST: set_box_bov1
# cp test_data/ex1.bov ex1.bov
# ur set_box_bov.awk ex1.bov     1 2 3    10 20 30
# mv ex1.bov           set_box_bov.out.bov

function strip_comments() {sub(/#.*/, "")}
function strip_tr_ws(s)   {  # strip trailing whitespaces
    sub(/^[ \t]*/, "", s)
    sub(/[ \t]*$/, "", s)
    return s
}
function emptyp(s) {return s ~ /^[\t ]*$/}

function parse_line(s)     { # sets `lhs' and `rhs'
    match(s, /^[^:]+:/)
    lhs = substr(s, RSTART, RLENGTH-1)
    lhs = strip_tr_ws(lhs)

    rhs = substr(s, RSTART+RLENGTH)
    rhs = strip_tr_ws(rhs)
}

function read_bov(fi,    oline) { # sets `bov_body' and `nl'
    nl = 0
    while (getline < fi > 0) {
	oline = $0
	strip_comments()
	if (emptyp($0)) {
	    bov_body[++nl]=oline
	    continue
	}
	parse_line($0) # sets `lhs' and `rhs'
	if      (lhs=="BRICK ORIGIN") bov_body[++nl] = lhs ": " xl " " yl " " zl
	else if (lhs=="BRICK SIZE"  ) bov_body[++nl] = lhs ": " Lx " " Ly " " Lz
	else                          bov_body[++nl] = oline
    }
    close(fi)
}

function update_bov(fi,    il) { # uses `bov_body' and `nl'
    for (il=1; il<=nl; il++)
	print bov_body[il]>fi
}

BEGIN {
    fi=ARGV[1] # input BOV

    xl=ARGV[2]; yl=ARGV[3]; zl=ARGV[4]
    xh=ARGV[5]; yh=ARGV[6]; zh=ARGV[7]

    Lx = xh - xl; Ly = yh - yl; Lz = zh - zl

    read_bov(fi)
    update_bov(fi)
}
