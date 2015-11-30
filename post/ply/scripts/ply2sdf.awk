#!/usr/bin/awk -f
#
# Convert ply to sdf

function req_var(v, n) {
    if (length(v)) return
    printf "(ply2ext.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	n, n
    exit 2
}

function gen_ext() { # generate an extended domain
    exl= xl - mrg; eyl= yl - mrg; ezl= zl - mrg
    exh= xh + mrg; eyh= yh + mrg; ezh= zh + mrg
}

function rint(x) {
    return x > int(x) ? int(x)+1 : int(x)
}

function mktemp() {
    "mktemp -d /tmp/ply2sdf.XXXXX" | getline n
    return n
}

BEGIN {
    req_var(xl, "xl"); req_var(yl, "yl"); req_var(zl, "zl")
    req_var(xh, "xh"); req_var(yh, "yh"); req_var(zh, "zh")
    req_var(gs, "gs"); req_var(Nv, "Nv"); req_var(mrg, "mrg")
    
    ply=ARGV[1]
    sdf=ARGV[2]
    print "(ply2sdf.awk) " ply " to " sdf

    gmrg = rint(mrg*gs) # margin in number of grid points
    mrg  = gmrg/gs
    printf "(ply2sdf.awk) need extra %d grid points\n", lmrg
    printf "(ply2sdf.awk) corrected mrg %g\n", mrg


    d = mktemp() # tmp directory

    system("ur ply2ext.awk")

    exit
}
