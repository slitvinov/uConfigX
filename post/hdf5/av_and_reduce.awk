#!/usr/bin/awk -f

BEGIN {
    # reduce dimension `d'
    # X: 0, Y: 1, Z: 2
    d = length(d) ? d : 0
    
    n = ARGV[1]
    gsub(/\.[^\.]+$/, "", n)
    path_xmf = n ".xmf"
    gsub(/.*\//, "" ,     n)
    
    new_xmf = n ".xmf"
    new_h5  = n ".h5"
    
    ARGV[1] = ""
    
    o = ARGV[2]
    gsub(/\.[^\.]+$/, "", o)
    gsub(/.*\//, "" ,     o)
    old_h5  = o ".h5"
}

FNR != NR {
    exit
}

function rem_field(s, f,     arr, ans, nn, sep) {
    nn = split(s, arr)
    for (i=1; i<=nn; i++) {
	if (i!=f) {
	    ans = ans sep arr[i]
	    sep = OFS
	}
    }
    return ans
}

function process_dim3(    l, r, c, aux) {
    l = substr($0, RSTART, RLENGTH)
    c_start = RSTART + RLENGTH

    aux = substr($0, RSTART+RLENGTH)
    
    match(aux, /"/)
    r = substr($0, c_start + RSTART)
    c_end   = c_start + RSTART
    
    c = substr($0, c_start, c_end - c_start)
    
    c = rem_field(c, d+1)
    return l c r
}

{
    gsub(old_h5, new_h5)

    gsub(/3DCORECTMesh/, "2DCORECTMesh")
    gsub(/ORIGIN_DXDYDZ/, "ORIGIN_DXDY")
    gsub(/Dimensions="3"/, "Dimensions=\"2\"")

    if (match($0, /[^<]*<DataItem Dimensions="/))
	$0 = process_dim3()

    if (match($0, /[^<]*<Topology TopologyType="2DCORECTMesh" Dimensions="/))
	$0 = process_dim3()

    if (($0 ~ /<DataItem Name="Origin"/) || ($0 ~ /<DataItem Name="Spacing"/)) {
	print $0 > path_xmf
	getline
	match($0, /[\t ]*/)
	print substr($0, RSTART, RLENGTH) rem_field($0, d+1) > path_xmf
    } else {
	print > path_xmf
    }
}
