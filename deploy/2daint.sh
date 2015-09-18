#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
rname=test #=rname=%my_dir_name%

# remote host name
uname=eceva
rhost="${uname}"@daint

# remote path name
rpath=/scratch/daint/"${uname}"/cylinder/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

post() {
    echo "mkdir -p ${rname} ; rsync -r -avz ${rhost}:${rpath}/${default_dir}/uDevice/mpi-dpd/h5/* ${rname}" >> ~/cylinder_rsync.sh
    echo "${rname}"                                                                                         >> ~/cylinder_local.list
    echo "${rhost}:${rpath}/${default_dir}"                                                                 >> ~/cylinder_remote.list
}

rt local/daint/setup.sh
post
