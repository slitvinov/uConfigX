#! /usr/bin/awk -f

# use to cut the directory name to the first `Nkeep' keys-values 
# usage: ./cutter.awk `directory_name' `Nkeep'
#   e.g: ./cutter.awk aa_1_bb_2_cc_3_dd_-4_ee_5 4


function min(x,y) {
  return x>y ? y : x
}

BEGIN {
  sep="_"
  longname=ARGV[1]
  Nkeep=ARGV[2]
  ARGV[1]=ARGV[2]=""

  N=split(longname, arr, sep)

  for (i=1; i<=min(N/2,Nkeep); i++) {
     key=arr[2*i-1]
     value=arr[2*i]
     osep = i==1 ? "" : sep
     ans=ans osep key sep value
}
  print ans

}
