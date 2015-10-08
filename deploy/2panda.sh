#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
rname=test #=rname=%my_dir_name%

# remote host name
uname=lisergey
rhost="${uname}"@panda

# remote path name
rpath=$HOME/SCRATCH/array1x5/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

post() {
    echo "mkdir -p ${rname} ; rsync -r -avz ${rhost}:${rpath}/${default_dir}/uDeviceX/mpi-dpd/* ${rname}"    >> ~/bigcyl_MORErbcs_rsync.sh
    echo "${rname}"                                                                                         >> ~/bigcyl_MORErbcs_local.list
    echo "${rhost}:${rpath}/${default_dir}"                                                                 >> ~/bigcyl_MORErbcs_remote.list
}

rt local/panda/setup.sh
post
