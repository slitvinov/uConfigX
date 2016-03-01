#!/bin/bash

set -e
set -u

make -C $UCX_PREFIX/post/ply

o=$1 # ouptut directory
p=$2 # input directory
box='-v xl=0 -v xh=32 -v yl=0 -v yh=56 -v zl=0 -v zh=56'
cutoff='-v c=0.5'

if test $# -ne 2
then
    printf "(ply2sort.sh)(ERROR) requres 2 argument (%d given)\n" $#
    exit 2
fi

b=`basename $p`
mkdir -p $o/$b/cm     # output directory
mkdir -p $o/$b/cm/ply # output directory for ply files
printf "(ply2sort.sh) processing: %s\n" "$b" > "/dev/stderr"

Nv_in=498 # nubmer of vertices
Nv="-v Nv=$Nv_in"

flist () { # returns input file list
    find $p/uConfigX/uDeviceX/mpi-dpd/ply -maxdepth 1 -name rbcs-*.ply | \
	grep -v wm | sort -g
}

repsufix () { # replace suffix `repsufix <filename> <old suffix> <new suffix>`
    local d=`dirname $1`
    local b=`basename $1`
    echo `repdir $d/${b/$2/$3}`
}

repdir () {
    local ob=`basename $p`
    local b=`basename $1`
    echo $o/$ob/cm/$b
}

gencm () {
    printf "(ply2sort.sh) running gencm\n" > "/dev/stderr"
    for f in $fl
    do
	local c=`repsufix $f ply cm`
	ur ply2ascii < $f | ur ply2cm.awk $Nv > $c
    done
}

genmap () {
    printf "(ply2sort.sh) running genmap\n" > "/dev/stderr"
    prev=`flist | awk 'NR==1'`
    prev=`repsufix $prev ply cm`
    for f in $fl
    do
	c=`repsufix $f ply cm`
	m=`repsufix $f ply map`
	ur nns.awk $box $cutoff $prev $c > $m
	prev=$c
    done
}

create_remap () {
    printf "(ply2sort.sh) running create_remap\n" > "/dev/stderr"
    rm -rf /tmp/d.$$
    for f in $fl
    do
	local m=`repsufix $f ply map`
	echo $m
    done | ur remap.awk -v d=/tmp/d.$$ > /tmp/rlist.$$
}

remap_cm () {
    printf "(ply2sort.sh) running remap_cm\n" > "/dev/stderr"    
    local rf=$1
    for f in $fl
    do
	c=`repsufix $f ply cm`
	r=`repsufix $f ply rm`
	read m
	paste $m $c | awk '{print $0, NR}' | sort -g | awk '{sub("^[^t]*\t", ""); print}' > $r
    done < "$rf"
}

image_cm () {
    prev=`awk 'BEGIN {print ARGV[1]}' $fl`
    prev=`repsufix $prev ply rm`
    
    for f in $fl
    do
	r=`repsufix $f ply rm`
	i=`repsufix $f ply im`
	ur cm2image.awk $box $prev $r > $i
	prev=$i
    done
}

wrap_cm () {
    for f in $fl
    do
	local i=`repsufix $f ply im`
	local w=`repsufix $f ply wm`
	ur image2unwrap.awk $box $i > $w
    done
}

addlevel () {
    local b=`basename $1`
    local d=`dirname  $1`
    echo $d/ply/$b
}

remap_ply() {
    for f in $fl
    do
	w=`repsufix $f ply wm`
	ur ply2ascii < $f | ur ply2unwrap.awk $box $Nv $w "-" | ur ply2binary > `addlevel $w.ply`
    done
}

fl=`flist`
gencm
genmap
create_remap
remap_cm /tmp/rlist.$$
image_cm
wrap_cm
remap_ply
