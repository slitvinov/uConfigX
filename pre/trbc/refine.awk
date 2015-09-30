#!/usr/bin/awk -f
# Refine triangulated surface

# Usage:
# r=<how to refine>
# ./refine.awk -v r="2 2 3" <intput file> > <output file>

function us(e, us_cmd, ans) {
    us_cmd = "us " e
    us_cmd | getline ans
    close(us_cmd)

    return ans
}

function build_cmd(nn, r_arr, cmd, sep, us_cu, cu, cmd0, i) {
    nn=split(r, r_arr)
    cmd = us("clean.awk") " | " us("unref.awk")
    
    for (i=1; i<=nn; i++) {
	ref_cmd = sprintf("refine%d.awk", r_arr[i])
	cmd0    = us(ref_cmd)
	cmd = cmd " | " cmd0
    }
    
    return cmd
}

BEGIN {
    cmd = build_cmd()
    print cmd
}

{
    print | cmd
}

