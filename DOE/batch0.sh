#!/bin/bash

. utils/ucx/env.sh

set -eux

tmp_d_file=`mktemp /tmp/batch0.XXXX`

if test -z "${TRANSFORM+x}"; then
    ur alcartesio.awk "$CART" > "$tmp_d_file"    
else
    # use transfrom file
    ur alcartesio.awk "$CART" | `us altransformio-pipe.sh` "$TRANSFORM" > "$tmp_d_file"
fi

cat "$tmp_d_file"  | xargs -n1 `us aldriver2.sh` $GITROOT
