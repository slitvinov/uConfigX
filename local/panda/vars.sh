# Variables definition for panda.ethz.ch

# setup PATH and UCX_PREFIX
. utils/ucx/env.sh

# parameters of the simulations

# this is linked to mpi-dpd/common.h
# and should be changed simultaneously
XSIZE_SUBDOMAIN=48
YSIZE_SUBDOMAIN=48
ZSIZE_SUBDOMAIN=48

xranks=1
yranks=1
zranks=1
tend=50

args="$xranks $yranks $zranks -tend=$tend -pushtheflow -walls -wall_creation_stepid=1 \
       -steps_per_dump=1000 dump_scalarfield -hdf5field_dumps"
