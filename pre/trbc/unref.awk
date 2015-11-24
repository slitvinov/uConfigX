#!/usr/bin/awk -f
#
# Removes references from tsdf file (see examples/)

# Usage:
# ./clean.awk examples/onesurface.trbc | ./unref.awk
#
# TEST: unref1
# ./clean.awk examples/onesurface.trbc | ./unref.awk > unref.out.trbc
#
# TEST: unref2
# ./clean.awk test_data/del.trbc | ./unref.awk > unref.out.trbc
#
# TEST: unref3
# ./clean.awk test_data/quadr.trbc | ./unref.awk > unref.out.trbc
#
# TEST: unref4
# ./clean.awk test_data/quadr_del.trbc | ./unref.awk > unref.out.trbc

function parse_def_id(    id, x, y, z) {
    id = $3
    x = $5; y=$6; z=$7
    key = x SUBSEP y SUBSEP z
    keys[key]++
    id2key[id] = key
}

function parse_def_pos() {
    x = $3; y = $4; z = $5
}

function parse_ref() {
    id = $3
    key = id2key[id]
}

function parse_del_id() {
    id = $3
    key = id2key[id]
}

function parse_plg_id(   n, i) {
    id_plg = $3
    n = $5
    parse_components(n)
    keys[key_plg]++
    id2key[id_plg] = key_plg
}

function parse_plg_n(   n) {
    n = $3
    parse_components(n)
}

function parse_components(n,    i, sep) {
    key_plg = ""
    for (i=1; i<=n; i++) {
	getline
	if ($1 == "def" && $2 == "id")
	    parse_def_id()
	else if ($1 == "def" && $2 == "pos")
	    parse_def_pos()
	else if ($1 == "ref")
	    parse_ref()
	sep     = key_plg ? SUBSEP : ""
	key_plg = key_plg sep key
	
	print "def key", key
    }
}


$1 == "def" && $2 == "id" {
    parse_def_id()
    print "def key", key
    next
}

$1 == "def" && $2 == "pos" {
    parse_def_pos()
    print "def key", key
    next
}

$1 == "ref" {
    parse_ref()
    print "def key", key
    next
}

$1 == "plg" && $2 == "id" {
    parse_plg_id()
    print "def key", key_plg
    next
}

$1 == "plg" && $2 == "n" {
    parse_plg_n()
    print "def key", key_plg
    next
}

$1 == "del" && $2 == "id" {
    parse_del_id()
    print "del key", key
    next
}

{
    print
}
