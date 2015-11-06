#!/bin/bash

set -e
set -u

make

box='-v xl=0 -v xh=24 -v yl=0 -v yh=120 -v zl=0 -v zh=24'
cutoff='-v c=3.0'
Nv='-v Nv=162'
#Nv='-v Nv=362'
#Nv='-v Nv=162'

#p=seed_111_dangle_-90_ha_1_Nv_362_cshape_0_phi_-1.5708_Lx_24_Ly_120_Lz_24_Rx_6
p=seed_111_dangle_0_ha_0.1_Nv_162_cshape_0_phi_-1.5708_Lx_24_Ly_120_Lz_24_Rx_6

flist () { # returns input file list
    find $HOME/$p/ply -name rbcs-*.ply | grep -v wm | sort -g | awk 'NR>1'
}

repsufix () { # replace suffix `repsufix <filename> <old suffix> <new suffix>`
    d=`dirname $1`
    b=`basename $1`
    echo $d/${b/$2/$3}
}

gencm () {
    for f in `flist`
    do
	c=`repsufix $f ply cm`
	./ply2ascii < $f | scripts/ply2cm.awk $Nv > $c
    done
}

genmap () {
    prev=`flist | awk 'NR==1'`
    prev=`repsufix $prev ply cm`
    for f in `flist`
    do
	c=`repsufix $f ply cm`
	m=`repsufix $f ply map`
	set -x
	scripts/nns.awk $box $cutoff $prev $c > $m
	set +x
	prev=$c
    done
}

create_remap () {
    rm -rf /tmp/d.$$
    for f in `flist`
    do
	m=`repsufix $f ply map`
	echo $m
    done | scripts/remap.awk -v d=/tmp/d.$$ > /tmp/rlist.$$
}

remap_cm () {
    rf=$1
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
	scripts/cm2image.awk $box $prev $r > $i
	prev=$i
    done
}

wrap_cm () {
    for f in `flist`
    do
	i=`repsufix $f ply im`
	w=`repsufix $f ply wm`
	scripts/image2unwrap.awk $box $i > $w
    done
}

remap_ply() {
    for f in `flist`
    do
	w=`repsufix $f ply wm`
	./ply2ascii < $f | scripts/ply2unwrap.awk $box $Nv $w "-" | ./ply2binary > $w.ply
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
