#!/bin/bash

. utils/ucx/env.sh

tmp_d_file=`mktemp /tmp/batch0.XXXX`

ur alcartesio.awk "$CART" > "$tmp_d_file"

while read pline
do
    ur aldriver2.sh $GITROOT $pline
done < "$tmp_d_file"
