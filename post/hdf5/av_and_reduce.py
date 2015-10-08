# average over several hdf5 files and one of the dimensions
import sys
import numpy as np
import h5py

av = h5py.File(sys.argv[1], 'w')

keys = ['v', 'u', 'w', 'density']

(Z, Y, X) = (0, 1, 2) # reverse order
d = Z # dimensions to average

# cut d'th  element from a tuple
def reduce_shape(s, d):
    return s[:d] + s[d+1:]

fst = h5py.File(sys.argv[2], 'r')
for k in keys:
    t = fst[k].dtype
    s = fst[k].shape
    s = reduce_shape(s, d)
    av.create_dataset(k, s, dtype=t, fillvalue=0.0)
fst.close()    

n = len(sys.argv[2:])
for fn in sys.argv[2:]:
    f = h5py.File(fn, 'r')
    for k in keys:
        av[k][:] += np.mean(f[k], axis=d)[:]

for k in keys:
    av[k][:] /= n

av.close()    

