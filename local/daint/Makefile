h5part = 1

LIBS_PREFIX = ${HOME}/uDevice/prefix

NVCC = nvcc -I${LIBS_PREFIX}/include -L${LIBS_PREFIX}/lib \
	-I$(CRAY_MPICH2_DIR)/include \
	-L$(CRAY_MPICH2_DIR)/lib -I$(HDF5_DIR)/include -I../

CXX = CC -L${LIBS_PREFIX}/lib \
	$(CRAY_CUDATOOLKIT_POST_LINK_OPTS) $(CRAY_CUDATOOLKIT_INCLUDE_OPTS) -L$(HDF5_DIR)/lib -I../
