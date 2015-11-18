#!/usr/bin/awk -f

BEGIN {
    SEP = "_"
    if (ARGC != 3) {
	printf "(keyval.awk)(ERROR) requres two arguments (given %d)\n", ARGC-1
	exit 1
    }
    
    d=ARGV[1] # directory name
    k=ARGV[2] # key

    ARGV[1]=ARGV[2]=""

    nn = split(d, arr, SEP)
    for (i=1; 2*i<=nn; i++) {
	kc = arr[2*i-1]
	vc = arr[2*i]
	if (kc == k) {
	    print vc
	    exit
	}
    }
    printf "(keyval.awk)(ERROR) cannot find filed: %s\n", k
    exit 1
}
