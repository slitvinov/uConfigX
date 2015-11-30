CXX?=g++
CXXFLAGS?=-O0 -g -Wall -Wextra

all: nslicebov

bovnslice: bovnslice.cpp
	$(CXX) nslicebov.cpp $(CXXFLAGS) -o nslicebov

.PHONY: clean

clean:
	-rm nslicebov
