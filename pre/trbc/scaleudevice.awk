#!/usr/bin/awk -f

# scale cell in "uDevice" format
# Usage:
# ur scaleudevice.awk -v sc=2 rbc.org.dat > rbc2.org.dat

# TEST: scaleudevice1
# ur scaleudevice.awk -v sc=2 test_data/rbc.org.dat > rbc2.out.dat

function init() {
    req_var(sc, "sc")
    xidx=4; yidx=5; zidx=6
}

function req_var(v, n) {
    if (length(v)==0) {
	printf "(scaleudevice.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
}

function read_until(s) {
    while (getline < fn > 0) {
	print
	if ($0 ~ s) break
    }
}

function rescale_atoms() {
    while (getline < fn > 0) {
	if (!NF) {
	    print
	    break
	}
	x=$(xidx); y=$(yidx); z=$(zidx)
	x*=sc; y*=sc; z*=sc
	$(xidx)=x; $(yidx)=y; $(zidx)=z
	print
    }
}

function read_rest() {
    while (getline < fn > 0)
	print
}

BEGIN {
    init()
    
    if (ARGC==2) {
	fn = ARGV[1]
	ARGV[1] = ""
    } else {
	fn = "-"
    }

    read_until("Atoms")
    getline < fn
    print

    rescale_atoms()
    read_rest()
    
}


