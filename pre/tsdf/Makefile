CXX?=g++
CXXFLAGS?=-O2 -g -Wall -Wextra

all: sdf2volume sdf2vtk

sdf2volume: sdf2volume.cpp
	$(CXX) sdf2volume.cpp $(CXXFLAGS) -o sdf2volume

sdf2vtk: sdf2vtk.cpp
	$(CXX) sdf2vtk.cpp $(CXXFLAGS) -o sdf2vtk
