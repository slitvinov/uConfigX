#!/bin/bash

PYTHON=$HOME/gerris-deploy/prefix/bin/python2.7
out_h5=$1
out_xmf=${out_h5/\.h5/.xmf}
shift

fst_h5=$1
fst_xmf=${fst_h5/\.h5/.xmf}

$PYTHON `us av.py` $out_h5 "$@"
ur av.awk $out_xmf $fst_xmf
