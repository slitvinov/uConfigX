#!/usr/bin/awk -f
# generate a seria of RBC coorrdinates

BEGIN {
    x_str="5 15 25 35 45"
    
    nn=split(x_str, x_arr)

    for (k in x_arr) {
	yc = 2.0
	zc = xc = x_arr[k]
	print xc, yc, zc
    }
}
