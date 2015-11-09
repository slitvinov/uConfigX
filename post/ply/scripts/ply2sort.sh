#!/bin/bash

set -e
set -u

make -C $UCX_PREFIX/post/ply

box='-v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24'
cutoff='-v c=3.0'

if test $# -ne 2
then
    printf "(ply2sort.sh)(ERROR) requres 2 argument (%d given)\n" $#
    exit 2
fi

o=$1 # ouptut directory
p=$2 # input directory

b=`basename $p`
mkdir -p $o/$b/cm     # output directory
mkdir -p $o/$b/cm/ply # output directory for ply files
printf "(ply2sort.sh) processing: %s\n" $b
cp    $p/uConfigX/uDeviceX/mpi-dpd/sdf.vti  $o/$b/cm/ply/

Nv_in=`ur keyval.awk $b Nv`
Nv="-v Nv=$Nv_in"

flist () { # returns input file list
    find $p/uConfigX/uDeviceX/mpi-dpd/ply -name rbcs-*.ply | grep -v wm | sort -g | awk 'NR>1'
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
    for f in `flist`
    do
	local c=`repsufix $f ply cm`
	ur ply2ascii < $f | ur ply2cm.awk $Nv > $c
    done
}

genmap () {
    prev=`flist | awk 'NR==1'`
    prev=`repsufix $prev ply cm`
    for f in `flist`
    do
	c=`repsufix $f ply cm`
	m=`repsufix $f ply map`
	ur nns.awk $box $cutoff $prev $c > $m
	prev=$c
    done
}

create_remap () {
    rm -rf /tmp/d.$$
    for f in `flist`
    do
	local m=`repsufix $f ply map`
	echo $m
    done | ur remap.awk -v d=/tmp/d.$$ > /tmp/rlist.$$
}

remap_cm () {
    local rf=$1
    for f in `flist`
    do
	c=`repsufix $f ply cm`
	r=`repsufix $f ply rm`
	read m
	paste $m $c | awk '{print $0, NR}' | sort -g | awk '{sub("^[^t]*\t", ""); print}' > $r
    done < "$rf"
}

image_cm () {
    prev=`flist | awk 'NR==1'`
    prev=`repsufix $prev ply rm`
    
    for f in `flist`
    do
	r=`repsufix $f ply rm`
	i=`repsufix $f ply im`
	ur cm2image.awk $box $prev $r > $i
	prev=$i
    done
}

wrap_cm () {
    for f in `flist`
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
    for f in `flist`
    do
	w=`repsufix $f ply wm`
	ur ply2ascii < $f | ur ply2unwrap.awk $box $Nv $w "-" | ur ply2binary > `addlevel $w.ply`
    done
}

gencm
genmap
create_remap
remap_cm /tmp/rlist.$$
image_cm
wrap_cm
remap_ply

# for f in `flist`
# do
#      w=`repsufix $f ply wm`
#      awk 'NR=='$1 $w
# done
