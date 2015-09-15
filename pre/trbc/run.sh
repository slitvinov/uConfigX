#!/bin/bash

./icosahedron.awk | ./clean.awk | ./unref.awk  | ./rbc.awk | ./unref2vtk.awk                                               > rbc0.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./rbc.awk | ./unref2vtk.awk                                > rbc1.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine.awk | ./rbc.awk | ./unref2vtk.awk                 > rbc2.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine.awk | ./refine.awk | ./rbc.awk | ./unref2vtk.awk  > rbc3.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./rbc.awk | ./unref2vtk.awk  > rbc4.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./rbc.awk | ./unref2vtk.awk  > rbc5.vtk
./icosahedron.awk | ./clean.awk | ./unref.awk  | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./refine.awk | ./rbc.awk | ./unref2vtk.awk  > rbc6.vtk

