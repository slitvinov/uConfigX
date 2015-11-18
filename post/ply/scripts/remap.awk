#!/usr/bin/awk -f

BEGIN {
    if (!d) {
	printf "(remap.awk) argument `d' (output directory should be given)\n" > "/dev/stderr"
	exit
    }
    psystem(sprintf("mkdir -p %s", d))
}

function psystem(s) {
    printf "(remap.awk) system: %s\n", s > "/dev/stderr"
    system(s)
}

function ofile() { # ouptut file name
    return sprintf("%s/%08d.remap", d, nf)
}

function aprint(    m, k, cmd) {
    pipe = sprintf("sort -g | awk '{print $2}' > %s", ofile())
    for (k in m)
	print k, m[k] | pipe 
    close(pipe)
    print ofile()
}

function init_map(    cid, pid) { # pid: previous `id', cid: current `id'
    while (getline < fn > 0) {
	cid++; pid = $1
	m[cid] = pid
    }
    aprint(m)    
}

function req_nonempty(a, k) {
    if (!a) {
	printf "(remap.awk) see empty map (k: %s, fn: %s)\n", k, fn > "/dev/stderr"
	exit
    }
    return a
}

function acopy(n, m,    k) { # copy array n to m
    for (k in m) delete m[k]
    for (k in n) m[k] = req_nonempty(n[k], k)
}

function update_map(   n, cid, pid, oid) {
    while (getline < fn > 0) {
	cid++; pid = $1; oid = m[pid]
	n[cid] = oid
    }
    acopy(n, m)
    aprint(m)
}

function process_map() {
    if (nf==1)
	init_map()
    else
	update_map()
}

/./ {
    nf++
    
    fn = $1
    process_map()
}
