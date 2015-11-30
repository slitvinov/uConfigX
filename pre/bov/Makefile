CXX?=g++
CXXFLAGS?=-O0 -g -Wall -Wextra

all: bovnslice

bovnslice: bovnslice.cpp
	$(CXX) bovnslice.cpp $(CXXFLAGS) -o bovnslice

.PHONY: clean

clean:
	-rm bovnslice
