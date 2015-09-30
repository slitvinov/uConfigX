#!/bin/bash

out_h5=$1
out_xmf=${out_h5/\.h5/.xmf}
shift

fst_h5=$1
fst_xmf=${fst_h5/\.h5/.xmf}

python av.py $out_h5 "$@"
./av.awk $out_xmf $fst_xmf