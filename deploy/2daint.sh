#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
rname=#=rname=%my_dir_name%

# remote host name
uname=eceva
rhost="${uname}"@daint

# remote path name
rpath=/scratch/daint/"${uname}"/RBCstretcing/"${rname}"

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

rt local/daint/setup.sh
