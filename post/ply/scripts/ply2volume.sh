#!/bin/bash

if test $# -eq 0
then
    ply="-"
else
    ply=$1
fi

ur ply2ascii < "$ply" | ur ply2trbc.awk | ur clean.awk | ur unref.awk | ur unref2vstats.awk | \
    awk 'NF{s+=$1} END {print s}'
