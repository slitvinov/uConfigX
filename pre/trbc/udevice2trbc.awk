#!/usr/bin/awk -f
# uDevice cell template file to  "unref" file format

# Example:
# ./udevice2trbc.awk examples/rbc.dat  | ./clean.awk | ./unref.awk  | ./unref2vtk.awk  > v.vtk

BEGIN {
    if (ARGC == 1) { # input is std
	fn = "-"
    } else {
	fn = ARGV[1]; ARGV[1] = ""
    }

    read_until("Atoms"); getline < fn; process_atoms()
    read_until("Bonds"); getline < fn; process_bonds()
    read_until("Angles"); getline < fn; process_angles()
}

function read_until(s) {
    while (getline < fn > 0 && $1 != s ) ;
}

function process_atoms(    x, y, z, id) {
    while (getline < fn > 0 && NF>0) {
	x=$4; y=$5; z=$6
	printf "def [id %d] [pos %g %g %g]\n", ++id, x, y, z
    }
}

function process_bonds(    id1, id2) {
    while (getline < fn > 0 && NF>0) {
	id1=$3; id2=$4
	printf "plg [n 2]\n"
	printf "ref [id %d]\n", id1
	printf "ref [id %d]\n", id2
    }
}

function process_angles(    id1, id2, id3) {
    while (getline < fn > 0 && NF>0) {
	id1=$3; id2=$4; id3=$5
	printf "plg [n 3]\n"
	printf "ref [id %d]\n", id1+1 # `ids' are shifted for Angles
				      # in uDevice
	printf "ref [id %d]\n", id2+1
	printf "ref [id %d]\n", id3+1
    }
}
