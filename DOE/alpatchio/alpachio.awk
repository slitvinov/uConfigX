#!/usr/bin/awk -f

function n2k(s) {
    return "%" s "%"
}

function gen_dir_name(i, name, key, val, d) {
    for (i=1; i<=ipar; i++) {
	name = namelist[i]
	key  = n2k(name)
	val =  rep[key]
	d = d sep name "_" val
	sep = "_"
    }
    return d
}

function reg_par(name, val) {
    	namelist[++ipar]     = name
	rep     [n2k(name)]    = val
}

BEGIN {
    pfile = ARGV[1]
    while (getline < pfile > 0)
	reg_par($1, $2)

    d =  gen_dir_name()

    reg_par("my_dir_name", d)


    ARGV[1] = ""
}

function rep_all(s,    i, new, old) {
    NREP = 0 # number of variable replaces
    for (i in rep) {
	old = i
	new = rep[i]
	NREP += gsub(old, new, s)
    }
    if (NREP) {
	printf "(alpachio.awk)(befor) %s:%d %s\n", FILENAME, NR, $0 > "/dev/stderr"
	printf "(alpachio.awk)(after) %s:%d %s\n", FILENAME, NR,  s > "/dev/stderr"
    }
    return s
}

function try_to_rep(sep,   fst, scd, ans, nn) {
    nn = split($0, arr, sep)
    if (nn<2)
	return 0

    fst = arr[1]
    scd = arr[2]
    ans = rep_all(scd) " " sep scd
    if (!NREP)
	return 0
    
    print ans
    return 1
}

{
    if (try_to_rep("//="))
	next

    if (try_to_rep("#="))
	next
}

{
    print
}
