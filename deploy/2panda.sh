#!/bin/bash

. utils/ucx/env.sh

set -eux

default_dir=uConfigX
iname=test #=iname=%my_dir_name%
Nkeep=10 # number of parameter in dir name
rname=`ur cutter.awk $iname $Nkeep`

# remote host name
uname=lisergey
rhost="${uname}"@localhost

# remote path name
name=ring.egg

rpath=$HOME/SYNC/$name/$rname

ur gcp "${default_dir}" "${rhost}":"${rpath}"

# execute command remotely with <gitroot> as a current directory
rt () {
    ssh "${rhost}" "cd ${rpath}/${default_dir} ; $@"
}

#rt local/panda_dbg/setup.sh
rt local/panda/setup.sh
