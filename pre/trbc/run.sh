#!/bin/bash

f=examples/onebond.trbc
./clean.awk $f  | ./unref.awk | ./unref2vtk.awk
