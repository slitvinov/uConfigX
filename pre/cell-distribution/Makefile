CXX?=g++
CXXFLAGS?=-O2 -g -Wall -Wextra

all: icsdf

icsdf: icsdf.cpp
	$(CXX) icsdf.cpp $(CXXFLAGS) -o icsdf

.PHONY: clean
clean:
	-rm sdf2vtk icsdf

