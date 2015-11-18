#!/bin/bash


level=$1
refine_cmd=`seq ${level} | awk '{printf sep " ./refine.awk "; sep="|"}'`
echo ${refine_cmd}

mkdir -p vtk
eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./rbc.awk | ./unref2vtk.awk > vtk/rbc${level}.vtk"
eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./rbc.awk | ./unref2normals.awk > vtk/normals${level}.vtk"

eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./unref2vtk.awk > vtk/sphere${level}.vtk"

# ./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine3.awk | ./unref2vba.awk | ./unref2udevice.awk -v sc=4.0 > ~/cycle.dat
# ./rbc2trbc.awk examples/rbc.dat | ./clean.awk | ./unref.awk  | ./refine3.awk | ./unref2vba.awk  | ./unref2udevice.awk

./icosahedron.awk | ./clean.awk | ./unref.awk  | ./unref2vba.awk  | ./unref2udevice.awk -v sc=2.795 > ~/cycle.dat 
