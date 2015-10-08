# Variables definition for panda.ethz.ch

# setup PATH and UCX_PREFIX
. utils/ucx/env.sh

# parameters of the simulations

# this is linked to mpi-dpd/common.h
# and should be changed simultaneously
XSIZE_SUBDOMAIN=24 #=XSIZE_SUBDOMAIN=%XS%
YSIZE_SUBDOMAIN=120 #=YSIZE_SUBDOMAIN=%YS%
ZSIZE_SUBDOMAIN=24 #=ZSIZE_SUBDOMAIN=%ZS%
R=6 #=R=%R%
lx=24 #=lx=%lx%
Nx=1 #=Nx=1
Ny=5 #=Ny=5

xranks=1
yranks=1
zranks=1
tend=10000
wall_creation_stepid=1

totArea0=10.0 #= totArea0=%totArea0%

# rotate initial RBC configuration around OX
phix=-1.5708

Nv=362 #=Nv=%Nv%
dump=5000

args="$xranks $yranks $zranks -tend=$tend -pushtheflow -walls -wall_creation_stepid=$wall_creation_stepid \
       -rbcs -steps_per_dump=5000 -dump_scalarfield -hdf5field_dumps"
