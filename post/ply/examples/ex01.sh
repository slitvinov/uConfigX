#!/bin/bash

./platoply -c  | ./ply2binary > cube.bin.ply
./platoply -c  | ./ply2binary | ./ply2ascii > cube.txt.ply
