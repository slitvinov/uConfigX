#!/bin/bash

. utils/ucx/env.sh

default_dir=uConfigX
 rname=numberdensity_10_dt_1e-3_kBT_0.404840_gammadpd_35_aij_0.25_stretchingforce_100_lmax_1.64_p_0.001412_cq_19.0476_kb_35_ka_2500_kv_3500_gammaC_50_totArea0_135_totVolume0_91  #= rname=%my_dir_name% 

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
