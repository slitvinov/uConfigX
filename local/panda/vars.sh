# Variables definition for panda.ethz.ch

# setup PATH and UCX_PREFIX
. utils/ucx/env.sh

# third party libraries
# this path should be used in local/panda/Makefile
LIBS_PREFIX=$HOME/uDevice/prefix
LIBS_WORK=$HOME/uDevice/work
CXX=/opt/mpich/bin/mpic++
CC=/opt/mpich/bin/mpicc

# this is linked to mpi-dpd/common.h
# and should be changed simultaneously
XSIZE_SUBDOMAIN=48 #=XSIZE_SUBDOMAIN=%XS%
YSIZE_SUBDOMAIN=48 #=YSIZE_SUBDOMAIN=%YS%
ZSIZE_SUBDOMAIN=48 #=ZSIZE_SUBDOMAIN=%ZS%

Lx=24 #= Lx=%Lx%
Ly=24 #= Ly=%Ly%
Lz=24 #= Lz=%Lz%
geom=cir #= geom=%geom%

xranks=1 #=xranks=%rx%
yranks=1 #=yranks=%ry%
zranks=1 #=zranks=%rz%
tend=999000
wall_creation_stepid=1000

totArea0=10.0 #= totArea0=%totArea0%

phix=1.570796326794897
Nv=1442 #=Nv=%Nv%
dump=20000
slevel=0

walls="-walls -wall_creation_stepid=$wall_creation_stepid"
rbcs="-rbcs -contactforces"

dumps="-steps_per_dump=$dump -dump_scalarfield -hdf5field_dumps" # -hdf5part_dumps"
args="$xranks $yranks $zranks -tend=$tend -pushtheflow $walls $rbcs $dumps"
