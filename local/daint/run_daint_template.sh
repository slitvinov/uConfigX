#!/bin/bash
#
#SBATCH --job-name=bigcyl_MORErbcs
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --output=rbc_stretching.%j.o
#SBATCH --error=rbc_stretching.%j.e

#======START=====
. local/panda/vars.sh
. local/daint/load_modules.sh

cd uDeviceX/mpi-dpd
aprun ./test ${args}
#=====END====
