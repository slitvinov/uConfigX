#!/usr/bin/awk -f

function parse_def_id() {
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

function parse_plg_id(   n, i, key_plg) {
    n = $5
    for (i=1; i<=n; i++) {
	getline
	if ($1 == "def" && $2 == "id")
	    parse_def_id()
	else if ($1 == "def" && $2 == "pos")
	    parse_def_pos()
	else if ($1 == "ref")
	    parse_ref()

	key_plg = key_plg ? (key_plg SUBSEP key) : key
	print "def key", key
    }
    print "def key", key_plg
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
    next
}

$1 == "del" && $2 == "id" {
    parse_del_id()
    print "del key", key
}
