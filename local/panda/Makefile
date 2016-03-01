h5part = 0
CUDA_ROOT=/usr/local/cuda-7.5
LIBS_PREFIX = ${HOME}/uDevice/prefix
NVCC = nvcc -g -I/opt/mpich/include/ -L/opt/mpich/lib/ -I/opt/hdf5_mpich/include/ -L/opt/hdf5_mpich/lib/ -I../ -I${LIBS_PREFIX}/include
CXX = /opt/mpich/bin/mpicxx -g -L/opt/mpich/lib/ -L/opt/hdf5_mpich/lib/ -I../
NVCC_LINK_FLAGS=-L${CUDA_ROOT}/bin/..//lib64 \
	-L${CUDA_ROOT}/bin/..//lib64/stubs   \
	-L${LIBS_PREFIX}/lib                \
	-Wl,-rpath=${CUDA_ROOT}/bin/..//lib64
CXXFLAGS = ${NVCC_LINK_FLAGS} -I${CUDA_ROOT}/include/
