#!/bin/bash

. local/panda/vars.sh

export HEX_COMM_FACTOR=2
export XVELAVG=10
export YVELAVG=3
export ZVELAVG=3

cd uDeviceX/mpi-dpd
./test $args
