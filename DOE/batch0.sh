#!/bin/bash

. utils/ucx/env.sh

set -x

tmp_d_file=`mktemp /tmp/batch0.XXXX`

ur alcartesio.awk "$CART" > "$tmp_d_file"

cat "$tmp_d_file" | while read pline
do
    echo "PLINE: " $pline
    ur aldriver2.sh $GITROOT $pline
done
