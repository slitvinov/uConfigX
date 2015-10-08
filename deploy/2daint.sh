#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
rname=test #=rname=%my_dir_name%

# remote host name
uname=lisergey
rhost="${uname}"@daint

# remote path name
rpath=/scratch/daint/"${uname}"/array1x5/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

name=array1x5
post() {
    echo "mkdir -p ${rname} ; rsync -r -avz ${rhost}:${rpath}/${default_dir}/uDeviceX/mpi-dpd/* ${rname}"    >> ~/${name}_rsync.sh
    echo "${rname}"                                                                                         >> ~/${name}_local.list
    echo "${rhost}:${rpath}/${default_dir}"                                                                 >> ~/${name}_remote.list
}

rt local/daint/setup.sh
post
