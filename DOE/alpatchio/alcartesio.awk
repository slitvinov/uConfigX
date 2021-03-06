#!/usr/bin/awk -f

# Takes "cartesian" file and produce a list of parameter strings
# Usage:
# ./alcartesio.awk cartesian_file > list_of_parameter_strings
#
# TEST: alcartesio1
# ur alcartesio.awk test_data/cartesian1.config  > alcartesio.out.config
#
# TEST: alcartesio2
# ur alcartesio.awk test_data/cartesian2.config  > alcartesio.out.config
#
# TEST: alcartesio3
# ur alcartesio.awk test_data/cartesian3.config  > alcartesio.out.config
#
# TEST: alcartesio4
# ur alcartesio.awk test_data/cartesian4.config  > alcartesio.out.config
#
# TEST: alcartesio5
# ur alcartesio.awk test_data/cartesian5.config  > alcartesio.out.config
#
# TEST: alcartesio6
# ur alcartesio.awk test_data/cartesian6.config  > alcartesio.out.config

BEGIN {
    curr[1] = ""
    icurr = 1

    FIELD_SEP = "_"
}

function is_parameter() {
    return substr($0, 1, 1)=="="
}

function norm_name(s) { # normalize name( remove "=")
    sub("^=", "", s)
    return s
}

# copy array
function copy(src, dest,    i) {
    for (i in src)
	dest[i] = src[i]
}

{
    sub(/#.*/, "")         # strip comments
}

!NF {                     # skip empty lines
    next
}

is_parameter() {
    name = norm_name($1)

    copy(curr, prev)
    iprev = icurr
    icurr = 0
    delete curr
    
    next
}

{
    # create directory name
    val = $1
    for (i = 1; i<=iprev; i++) {
	sep = prev[i] ? FIELD_SEP : ""
	curr[++icurr] = prev[i] sep name FIELD_SEP val
    }
}

END {
    for (i = 1; i<=icurr; i++) # print all directory names names
	print curr[i]
}
