#!/bin/bash

# do in-place batch replace in a list of files
# Usage:
# ./replace.sh A B [file1 ...]

old=$1; shift
new=$1; shift

t=`mktemp /tmp/rep.XXX`

for f
do
    sed "s,$old,$new,g" "$f" >  "$t"
    mv "$t" "$f"
done
