#!/bin/bash
# al-patch files in-place
#   Usage:
#   ./alpachio.sh <config_file> [file1 file2 file3]
#
# TEST: alpachio1
# cp test_data/common.cpp common.tmp.cpp
# ./alpachio.sh test_data/alpatchi1.config common.tmp.cpp
# cp common.tmp.cpp       common.out.cpp
#
# TEST: alpachio2
# cp test_data/common2.cpp common.tmp.cpp
# ./alpachio.sh test_data/alpatchi1.config common.tmp.cpp
# cp common.tmp.cpp       common.out.cpp
#
# TEST: alpachio3
# cp test_data/common3.cpp common.tmp.cpp
# ./alpachio.sh test_data/alpatchi1.config common.tmp.cpp
# cp common.tmp.cpp       common.out.cpp
#
# TEST: alpachio4
# cp test_data/common4.mac common.tmp.cpp
# ./alpachio.sh test_data/alpatchi1.config common.tmp.cpp
# cp common.tmp.cpp       common.out.cpp
#
# TEST: alpachio5
# cp test_data/common5.mac common.tmp.cpp
# ./alpachio.sh test_data/alpatchi1.config common.tmp.cpp
# cp common.tmp.cpp       common.out.cpp

set -u
config=$1
shift

t=`mktemp /tmp/al.XXXXX`
for f
do
    ur alpachio.awk "$config" "$f" >  "$t"
    mv             "$t"              "$f"
done

rm -rf "${t?}"
