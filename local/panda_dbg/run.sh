#!/bin/bash

. local/panda/vars.sh

cd uDeviceX/mpi-dpd

printf "(run_dbg.sh) to run gdb\n"

gdb=/usr/local/cuda-6.5/bin/cuda-gdb
host=panda

# print a command for remote debuging in emacs
# do `(C-x e) at the end of the command

echo "(gud-gdb \"" $gdb "--fullname /ssh:"$host":"`pwd`"/test_dbg -ex \\\"start " $args "\\\"\")"
