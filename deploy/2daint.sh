#!/bin/bash

. utils/ucx/env.sh

set -xeu

default_dir=uConfigX
iname=test #=iname=%my_dir_name%
Nkeep=14 # number of parameter in dir name
rname=`ur cutter.awk $iname $Nkeep`

# remote host name
uname=lisergey
rhost="${uname}"@daint

# remote path name
name=slow

# remote path name
rpath=/scratch/daint/"${uname}"/$name/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

rt local/daint/setup.sh
#post
