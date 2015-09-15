#!/usr/bin/awk -f

# force numeric
function fn(x) {
    return x+0
}

BEGIN {
    id_idx = 1; x_idx = 4; y_idx = 5; z_idx = 6
    
    f = ARGV[1]
    
    while (getline < f > 0 && $1 != "Atoms" ) ;
    getline < f # empty line
    
    while (getline < f > 0 && NF>0) {
	x = $(x_idx); y = $(y_idx) ; z = $(z_idx); id = $(id_idx)
	printf "def [id %d] [pos %.12g %.12g %.12g]\n", id-1, x, y, z
    }

    getline < f # bond line
    getline < f # empty line
    while (getline < f > 0 && NF>0) {
    	id1 = $3
    	id2 = $4	

    	printf "plg [n 2]\n"
    	printf "ref [id %d]\n", id1
    	printf "ref [id %d]\n", id2
    	printf "\n"
    }

    getline < f # angles line
    getline < f # empty line
    while (getline < f > 0 && NF>0) {
	id1 = $3
	id2 = $4
	id3 = $5
	
	printf "plg [n 3]\n"
	printf "ref [id %d]\n", id1
	printf "ref [id %d]\n", id2
	printf "ref [id %d]\n", id3	
	printf "\n"
    }

    getline < f # dihedrals line
    getline < f # empty line
    while (getline < f > 0 && NF>0) {
    	id1 = $3-1
    	id2 = $4-1
    	id3 = $5-1
    	id4 = $6-1
	
    	printf "plg [n 4]\n"
    	printf "ref [id %d]\n", id1
    	printf "ref [id %d]\n", id2
    	printf "ref [id %d]\n", id3
    	printf "ref [id %d]\n", id4
    	printf "\n"
    }
    
}
