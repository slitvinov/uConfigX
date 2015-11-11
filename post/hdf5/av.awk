#!/usr/bin/awk -f

BEGIN {
    n = ARGV[1]
    gsub(".[^.]+$", "", n)
    path_xmf = n ".xmf"
    gsub(/.*\//, "" ,     n)
    
    new_xmf = n ".xmf"
    new_h5  = n ".h5"
    
    ARGV[1] = ""
    
    o = ARGV[2]
    gsub(".[^.]+$", "", o)
    gsub(/.*\//, "" ,     o)
    old_h5  = o ".h5"
}

FNR != NR {
    exit
}

{
    gsub(old_h5, new_h5)
    print > path_xmf
}
