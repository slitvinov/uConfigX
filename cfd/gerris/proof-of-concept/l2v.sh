#!/bin/bash

(cd vtk

 (
     printf "!NBLOCKS %d\n" 24
     find . -name '*.vtk' | sort -g
 ) > v.visit
)
