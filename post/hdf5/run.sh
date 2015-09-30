#!/bin/bash

set -e

~/prefix-pkgsrc-master64/bin/python2.7 flowp.py av.h5 ~/tmp/h5/flowfields-[0-9]*.h5
awk -f flowp.awk av.xmf ~/tmp/h5/flowfields-[0-9]*.xmf
