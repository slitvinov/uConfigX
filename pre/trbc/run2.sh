#!/bin/bash


level=$1
refine_cmd=`seq ${level} | awk '{printf sep " ./refine.awk "; sep="|"}'`
echo ${refine_cmd}

mkdir -p vtk
eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./rbc.awk | ./unref2vtk.awk > vtk/rbc${level}.vtk"
eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./rbc.awk | ./unref2normals.awk > vtk/normals${level}.vtk"

eval "./icosahedron.awk | ./clean.awk | ./unref.awk  | ${refine_cmd}  | ./unref2vtk.awk > vtk/sphere${level}.vtk"
