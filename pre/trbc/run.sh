#!/bin/bash

# ./icosahedron.awk | ./clean.awk | ./unref.awk  | ./unref2vtk.awk

./icosahedron.awk | ./clean.awk | ./unref.awk  | \
    #    ./refine.awk  | ./refine.awk | ./refine.awk | \
    ./refine.awk | \
    ./rbc.awk | \
    ./unref2vtk.awk 
