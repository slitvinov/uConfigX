#!/usr/bin/awk -f


NF {
    n++
    x = $1
    sum  += x
}

END {
    E = sum/n
    print E
}
