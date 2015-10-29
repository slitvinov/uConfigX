#!/bin/bash

. local/panda/vars.sh

flist="uDeviceX/mpi-dpd/Makefile uDeviceX/cuda-rbc/Makefile"
cu="uDeviceX/cuda-rbc/rbc-cuda.cu"

function ctrl_c() {
    local/panda_dbg/restore.sh $flist
    local/panda_dbg/restore.sh $cu    
}

function compile() {
    local/panda_dbg/backup.sh  $flist
    local/panda_dbg/replace.sh '-O[234]'         '-O0'                    $flist
    local/panda_dbg/replace.sh '-DNDEBUG'        ''                       $flist
    local/panda_dbg/replace.sh ' __forceinline__ ' '  '                   $cu

    # trap C-c so I can restore Makefile
    trap ctrl_c INT
    local/panda/compile.sh
    trap -      INT

    local/panda_dbg/restore.sh $flist
    local/panda_dbg/restore.sh $cu
    
    mv uDeviceX/mpi-dpd/test uDeviceX/mpi-dpd/test_dbg
}

compile
local/panda/pre.sh
local/panda_dbg/run.sh
