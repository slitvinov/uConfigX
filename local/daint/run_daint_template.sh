#!/bin/bash
#
#SBATCH --job-name=1p1c
#SBATCH --time=16:00:00
#SBATCH --nodes=1 #=#SBATCH --nodes=%np%
#SBATCH --ntasks-per-node=1
#SBATCH --output=time_average.%j.o
#SBATCH --error=time_average.%j.e

# ======START=====
. local/panda/vars.sh
. local/daint/load_modules.sh

export HEX_COMM_FACTOR=2
export XVELAVG=10
export YVELAVG=3
export ZVELAVG=3

cd uDeviceX/mpi-dpd
aprun -B ./test ${args}
# =====END====
