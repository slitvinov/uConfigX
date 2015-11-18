#!/usr/bin/awk -f
#
# Reorder rows in the files accoriding to map files
#
# Usage:
# echo f1 m12 f2 m23 f3     | ./remapcm.awk -v s=<suffix> -v o=<output director>
# echo f1 m12 f2 m23 f3 m34 | ./remapcm.awk
# f1, f2, f3: files with `n' rows
# m12, m23  : maps (see nns.awk)
#
# Note: `f1' is copyied unmodified
#       last map file is ignored

function get_output_name(bn, ans) {
    if (o) {
	"basename " fn | getline bn # basename of the file name
	bn = s ? bn "." s : bn
	
	return o "/" bn
    } else if (s)
	return fn "." s
    else {
	printf "(remapcm.awk) at least one the options `o' or `s' should be given\n" > "/dev/stderr"
	exit 2
    }
}

function req_nonempty(a, k) {
    if (!a) {
	printf "(remapcm.awk) see empty map (k: %s, fn: %s)\n", k, fn > "/dev/stderr"
	exit 2
    }
    return a
}

function is_datafile(n) { return n%2 == 1 } # every odd file is data
                                            # every even file is map

function process_first(    i, line, out) { # sets the number of rows in the files (`n')
    out = get_output_name()
    while (getline line < fn > 0) {
	print line > out
	omap[i] = ++i
    }
    n = i
    close(out)
}

function update_map(    i, n_map, pid, cid) {
    while (getline pid < fn > 0) { # pid: previous id
	cid = ++i # current id
	n_map[cid] = omap[pid]
    }
    acopy(n_map, omap)
}

function process_data(   oid, cid, i, data) {
    out = get_output_name()
    
    while (getline data[++i] < fn > 0) ;
    
    for (oid=1; oid<=n; oid++) {
	cid = omap[oid]
	print data[cid] > out
    }
    close(out)
}

function acopy(n, m,    k) { # copy array n to m
    for (k in m) delete m[k]
    for (k in n) m[k] = req_nonempty(n[k], k)
}

/./ {
    nf++
    fn = $0 # file name
    if (nf==1)
	process_first()
    else if (is_datafile(nf))
	process_data()
    else # map file
	update_map()
}
