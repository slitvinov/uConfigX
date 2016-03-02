#!/bin/bash

awk -v d2=0 -f gboxes.awk script.templ.gfs  > s.gfs
gerris3D -B s.gfs
