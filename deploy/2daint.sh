#!/bin/bash

. utils/ucx/env.sh

set -x

default_dir=uConfigX
iname=test #=iname=%my_dir_name%
Nkeep=14 # number of parameter in dir name
rname=`ur cutter.awk $iname $Nkeep`

# remote host name
uname=lisergey
rhost="${uname}"@daint

name=uTest
# remote path name
rpath=/scratch/daint/"${uname}"/$name/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

post() {
    echo "mkdir -p ${rname} ; rsync -r -avz ${rhost}:${rpath}/${default_dir}/uDeviceX/mpi-dpd/* ${rname}"    >> ~/${name}_rsync.sh
    echo "${rname}"                                                                                         >> ~/${name}_local.list
    echo "${rhost}:${rpath}/${default_dir}"                                                                 >> ~/${name}_remote.list
}

rt local/daint/setup.sh
post
