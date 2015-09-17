# average hdf5 files

import sys
import h5py

av = h5py.File(sys.argv[1], 'w')

keys = ['v', 'u', 'w', 'density']

fst = h5py.File(sys.argv[2], 'r')
for k in keys:
    t = fst[k].dtype
    s = fst[k].shape
    av.create_dataset(k, s, dtype=t, fillvalue=0.0)
fst.close()    

n = len(sys.argv[2:])
for fn in sys.argv[2:]:
    f = h5py.File(fn, 'r')
    for k in keys:
        av[k][:] += f[k][:]

for k in keys:
    av[k][:] /= n

av.close()    

