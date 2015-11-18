#!/bin/bash

. local/panda/vars.sh

ur icosahedron.awk  | ur clean.awk | ur unref.awk | ur refine.awk -v r="2" | ur unref2vba.awk | \
    ur unref2udevice.awk -v totArea0=$totArea0
