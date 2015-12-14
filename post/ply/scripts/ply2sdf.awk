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
    Lx = xh - xl; nx = Lx*gs
    Ly = yh - yl; ny = Ly*gs
    Lz = zh - zl; nz = Lz*gs

    exl= xl - mrg; eyl= yl - mrg; ezl= zl - mrg
    exh= xh + mrg; eyh= yh + mrg; ezh= zh + mrg

    enx = nx + 2*gmrg; eny = ny + 2*gmrg; enz = nz + 2*gmrg
}

function rint(x) {
    return x > int(x) ? int(x)+1 : int(x)
}

function mktemp(   n) {
    #"mktemp -d /tmp/ply2sdf.XXXXX" | getline n
    #return n
    return "/home/lisergey/tmp"
}

function lsystem(cmd, rc) {
    printf "(ply2sdf.awk) executing:\n%s\n", cmd
    rc = system(cmd)
    if (rc) {
	printf "(ply2sdf.awk)(ERROR)\n"
	exit rc
    }
}

BEGIN {
    req_var(xl, "xl"); req_var(yl, "yl"); req_var(zl, "zl")
    req_var(xh, "xh"); req_var(yh, "yh"); req_var(zh, "zh")
    req_var(gs, "gs"); # grid scale
    req_var(Nv, "Nv"); req_var(mrg, "mrg")
    
    ply=ARGV[1]
    sdf=ARGV[2]
    print "(ply2sdf.awk) " ply " to " sdf

    gen_ext()

    printf "(ply2sdf.awk) need extra %d grid points\n", lmrg
    printf "(ply2sdf.awk) corrected mrg %g\n", mrg
    d = mktemp() # tmp directory
    box = sprintf("-v   xl=%g   -v  yl=%g -v  zl=%g -v  xh=%g -v  yh=%g -v  zh=%g",
		  xl, yl, zl,     xh, yh, zh)
    ebox = sprintf("-v   exl=%g   -v  eyl=%g -v  ezl=%g -v  exh=%g -v  eyh=%g -v  ezh=%g",
		  exl, eyl, ezl,  exh, eyh, ezh)

    tply = sprintf("%s/t.ply", d) # ascii version of ply
    cmd  = sprintf("ur ply2ascii < %s > %s", ply, tply)
    lsystem(cmd)

    eply = sprintf("%s/e.ply", d) # extended ply
    cmd = sprintf("ur ply2ext.awk %s    %s -v Nv=%d     %s > %s",
		  box , ebox, Nv,
		  tply, eply)
    lsystem(cmd)

    gts = sprintf("%s/g.gts", d)
    sc = mrg > 0 ? 1/mrg : 1 # rescale geometry

    cmd = sprintf("ur ply2gts.awk %s | ur gtstransform.awk -v sc=%g > %s",
		  eply, sc, gts)
    lsystem(cmd)

    bov0 = sprintf("%s/wall.bov", d)
    cmd  = sprintf("ur gts2bov.sh %s %s    %s %s %s    %s %s %s    %s %s %s\n",
		  gts, bov0,
		  sc*xl, sc*yl, sc*zl,
		  sc*xh, sc*yh, sc*zh,
		  nx, ny, nz)
    lsystem(cmd)
    printf "cat %s\n", bov0
    print sc, (exh - exl)/(enx-1), enx

    bov1 = sprintf("%s/b1.bov", d)
    cmd  = sprintf("ur transformbov.awk %s %s %g", bov0, bov1, -1/sc)
    lsystem(cmd)

    bov2 = sprintf("%s/b2.bov", d)
    cmd = sprintf("ur nslicebov.awk %s %s  %s %s %s    %s %s %s",
     		  bov1, bov2,
     		  gmrg, gmrg, gmrg,
		  enx - gmrg - 1, eny - gmrg - 1, enz - gmrg - 1)
    lsystem(cmd)

    cmd = sprintf("ur set_box_bov.awk %s    %s %s %s    %s %s %s",
		  bov2, xl, yl, zl,    xh, yh, zh)
    lsystem(cmd)

    cmd = sprintf("ur bov2sdf.awk %s %s", bov2, sdf)
    lsystem(cmd)

    exit
}
