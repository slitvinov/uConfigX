#!/bin/bash

set -eu
nproc=1

oPATH=$PATH

export PATH=$HOME/gerris-deploy/prefix/bin:$PATH
gdb=/usr/bin/gdb
host=panda
gerris_dbg=$HOME/gerris-deploy/prefix-dbg/bin/gerris2D
gerris_run=$HOME/gerris-deploy/prefix/bin/gerris2D

gerris_bin=$HOME/gerris-deploy/prefix/bin
pcp=/home/lisergey/gerris-deploy/prefix/lib/pkgconfig

./gboxes.awk -v d2=1 -v nproc=$nproc script.templ.gfs > script.gfs
p=`pwd`
gfs=script.gfs
args="--verbose $gfs"

mkdir -p vtk0 vtk1 vtk2 vtk3 vtk4 vtk5 vtk6 vtk7 vtk8

cat <<EOF
(gud-gdb "\
          $gdb --fullname /ssh:panda:$gerris_dbg     \
               -ex \"set env PKG_CONFIG_PATH = $pcp\" \
               -ex \"path   $gerris_bin\"            \
               -ex \"cd $p\"                         \
               -ex \"start  $args\"")
EOF

mpirun -np $nproc $gerris_run $args
