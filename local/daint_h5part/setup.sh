#!/bin/bash

set -eux

. local/panda/vars.sh

DISTNAME=H5Part-1.6.6
WRKSRC=$LIBS_WORK/$DISTNAME
DISTFILE=$DISTNAME.tar.gz

FETCH_CMD=wget \
	 ur fetch -d "$LIBS_WORK" $DISTFILE https://codeforge.lbl.gov/frs/download.php/file/387/


H5PART_COOKIE=$LIBS_PREFIX/.h5part

if test -f "$H5PART_COOKIE"
then
    printf "(local/daint_h5part/setup.sh) see cookie in %s\n" "$H5PART_COOKIE"
    exit
fi

ur extract -d "$LIBS_WORK" "$LIBS_WORK/$DISTFILE"
. local/daint/load_modules.sh

( # patch
    cd "$WRKSRC"
    cd src
    patch  -b -p1 H5Part.c
)  < local/panda_h5part/H5Part.patch

( # configure
    cd "$WRKSRC"
    ./configure --enable-parallel --with-hdf5=$HDF5_DIR \
		--prefix="$LIBS_PREFIX" \
		CXX=CC CC=cc
)

( # build
    cd "$WRKSRC"
    make
)

( # install
    cd "$WRKSRC"
    make install
)

( # put cookie
    printf "(local/daint_h5part/setup.sh) create cookie in %s\n" "$H5PART_COOKIE"
    touch "$H5PART_COOKIE"
)
