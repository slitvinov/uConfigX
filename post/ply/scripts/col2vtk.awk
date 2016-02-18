#!/usr/bin/awk -f
# 
# Convert column data to vtk
# input file
# X1 Y1 Z1 Filed1
# X2 Y2 Z2 Filed2
# ...
# XN YN Zn FiledN

{
    xx[n]=$1; yy[n]=$2; zz[n]=$3; ff[n]=$4
    n++
}

function file_version() {
    printf "# vtk DataFile Version 2.0\n"
}

function header() {
    printf "Created with col2vtk.awk\n"
}

function format() {
    printf "ASCII\n" # ASCII, BINARY
}

function topology() {
    # STRUCTURED_POINTS
    # STRUCTURED_GRID
    # UNSTRUCTURED_GRID
    # POLYDATA
    # RECTILINEAR_GRID
    # FIELD
    
    #structured_points()
    # structured_grid()
    # unstructured_grid()
    polydata()
    printf "\n"
}

function polydata(    i, x, y, z, dataType) {
    dataType = "float"

    printf "DATASET POLYDATA\n"
    printf "POINTS %d %s\n", n, dataType
    for (i=0; i<n; i++) {
	x = xx[i]; y = yy[i]; z = zz[i]
	printf "%e %e %e\n", x, y, z
    }
    
    printf "VERTICES %d %d\n", 1, n+1
    printf "%d\n", n
    for (i=0; i<n; i++)
	printf "%d\n", i
}

function dataset(dataName, dataType, i, f) {
    dataName = "d"
    dataType = "float"

    printf "POINT_DATA %d\n", n
    printf "SCALARS %s %s\n", dataName, dataType
    printf "LOOKUP_TABLE default\n"

    for (i=0; i<n; i++) {
	f = ff[i]
	printf "%e\n", f
    }
}

END {
    file_version()
    header()
    format()

    topology()
    dataset()
}
