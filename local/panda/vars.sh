# Variables definition for panda.ethz.ch

# setup PATH and UCX_PREFIX
. utils/ucx/env.sh

# parameters of the simulations

# this is linked to mpi-dpd/common.h
# and should be changed simultaneously
XSIZE_SUBDOMAIN=48 #=XSIZE_SUBDOMAIN=%XS%
YSIZE_SUBDOMAIN=48 #=YSIZE_SUBDOMAIN=%YS%
ZSIZE_SUBDOMAIN=48 #=ZSIZE_SUBDOMAIN=%ZS%

Lx=24 #= Lx=%Lx%
Ly=24 #= Ly=%Ly%
Lz=24 #= Lz=%Lz%

Nx=1 #= Nx=%Nx%
Ny=5 #= Ny=%Ny%
Nz=1 #= Nz=%Nz%

Rx=6 #= Rx=%Rx%
Ry=6 #= Ry=%Ry%

xranks=1 #=xranks=%rx%
yranks=1 #=yranks=%ry%
zranks=1 #=zranks=%rz%
tend=300
wall_creation_stepid=1000

totArea0=10.0 #= totArea0=%totArea0%

Nv=362 #=Nv=%Nv%
dump=5000
walls="-walls -wall_creation_stepid=$wall_creation_stepid"

args="$xranks $yranks $zranks -tend=$tend -pushtheflow -contactforces $walls \
      -rbcs -steps_per_dump=$dump -dump_scalarfield -hdf5field_dumps"
