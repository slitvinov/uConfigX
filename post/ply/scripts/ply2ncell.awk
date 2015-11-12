#!/usr/bin/awk -f

# get the number of triangulated objects in ply file. Assume that all
# of the object have the same number of vertices (`Nv')
# Usage:
# ./ply2ncell.awk -v Nv=<Nv> <ply file>
# 
# TEST: ply2ncell1
# ur ply2ncell.awk -v Nv=486 test_data/rbcs-0001.ply > ply2ncell.out.txt
#
# TEST: ply2ncell2
# ur ply2ncell.awk -v Nv=1442 test_data/f.000001.ply > ply2ncell.out.txt

function req_var(v, n) {
    if (length(v)==0) {
	printf "(ply2ncell.awk)(ERROR) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
}

function integerp(n)  { # integer predicate
    return n == int(n)
}

BEGIN {
    req_var(Nv, "Nv")
}

$0 ~ /^element vertex/ {
    Nv_total = $3
    Npart = Nv_total / Nv

    if (!integerp(Npart)) {
	printf "(ply2ncell.awk)(ERROR) `Nv_total'/`Nv' is not integer \n" > "/dev/stderr"
	printf "(ply2ncell.awk)(ERROR) Nv = %g, Nv_total = %g, Npart = %g\n",
	    Nv, Nv_total, Npart > "/dev/stderr"
	exit 2
    }

    print Npart
}

