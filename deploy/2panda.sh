#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
iname=test #=iname=%my_dir_name%
Nkeep=10 # number of parameter in dir name
rname=`ur cutter.awk $iname $Nkeep`

# remote host name
uname=lisergey
rhost="${uname}"@localhost

# remote path name
n=gerris
rpath=$HOME/SYNC/$n/$rname

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

post() {
    echo "mkdir -p ${rname} ; rsync -r -avz ${rhost}:${rpath}/${default_dir}/uDeviceX/mpi-dpd/* ${rname}"    >> ~/${n}_rsync.sh
    echo "${rname}"                                                                                         >> ~/${n}_local.list
    echo "${rhost}:${rpath}/${default_dir}"                                                                 >> ~/${n}_remote.list
}

#rt local/panda/setup_dbg.sh
rt local/panda/setup.sh
post
