CXX?=g++
CXXFLAGS?=-O0 -g -Wall -Wextra

all: nslicebov transformbov

%: %.cpp
	$(CXX) $< $(CXXFLAGS) -o $@

.PHONY: clean

clean:
	-rm nslicebov transformbov
