/* Slice BOV data file

Usage:
./bovnslice <input data file> <output data file> \
            <nxl> <nyl> <nzl>                    \
            <sxl> <syl> <szl> <sxh> <syh> <szh>

<nx> <ny> <nz>: old sizes

Output `data' is
data[sxl:sxh][syl:syh][szl:szh]

Note: assumes one component float data

*/

#include <cstdio>
#include <cstdlib>
#include <vector>
#include <algorithm>

typedef float btype; // type in BOV file

enum DIM {X, Y, Z};

int n[3], nn[3];
int sl[3], sh[3];

void bond_limits() {
  using std::max;
  using std::min;
  sl[X] = max(sl[X], 0); sl[Y] = max(sl[Y], 0); sl[Z] = max(sl[Z], 0);
  sh[X] = min(sh[X], n[X]-1); sh[Y] = min(sh[Y], n[Y]-1); sh[Z] = min(sh[Z], n[Z]-1);
}

int main(int argc, char *argv[]) {
  if (argc != 12) {
    fprintf(stderr, "(bovnslice.cpp)(ERROR) not enough argumetns\n");
    exit(2);
  }

  using namespace std;
  char* fn = argv[1];
  char* of = argv[2];

  printf("(bovnslice.cpp) fn, of: %s %s\n", fn , of);

  n[X] = atoi(argv[3]);
  n[Y] = atoi(argv[4]);
  n[Z] = atoi(argv[5]);  
  printf("(bovnslice.cpp) nx ny nz: %d %d %d\n", n[X], n[Y], n[Z]);

  sl[X] = atoi(argv[6]);
  sl[Y] = atoi(argv[7]);
  sl[Z] = atoi(argv[8]);

  sh[X] = atoi(argv[9]);
  sh[Y] = atoi(argv[10]);
  sh[Z] = atoi(argv[11]);
  printf("(bovnslice.cpp) sxl syl szl: %d %d %d\n", sl[X], sl[Y], sl[Z]);
  printf("(bovnslice.cpp) sxh syh szh: %d %d %d\n", sh[X], sh[Y], sh[Z]);
  bond_limits();
  printf("(bovnslice.cpp) bond_limits()\n");
  printf("(bovnslice.cpp) sxl syl szl: %d %d %d\n", sl[X], sl[Y], sl[Z]);
  printf("(bovnslice.cpp) sxh syh szh: %d %d %d\n", sh[X], sh[Y], sh[Z]);

  int nsize = n[X] * n[Y] * n[Z];
  nn[X] = sh[X] - sl[X] + 1;
  nn[Y] = sh[Y] - sl[Y] + 1;
  nn[Z] = sh[Z] - sl[Z] + 1;
  printf("(bovnslice.cpp) nnx nny nnz: %d %d %d\n", nn[X], nn[Y], nn[Z]);
  
  int osize = nn[X] * nn[Y] * nn[Z];
  
  FILE *fp = fopen(fn, "r");
  if (fp == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  vector<btype> ndata(nsize);
  fread(&ndata[0], sizeof ndata[0], ndata.size(), fp);
  fclose(fp);

  vector <btype> odata(osize);

  int ix, iy, iz; /* old index */
  int jx, jy, jz; /* new index */
  int idx, jdx;

  for (iz=sl[Z]; iz<=sh[Z]; iz++) {
    jz = iz - sl[Z];
    for (iy=sl[Y]; iy<=sh[Y]; iy++) {
      jy = iy - sl[Y];
      for (ix=sl[X]; ix<=sh[X]; ix++) {
	jx = ix - sl[X];
	idx = iz *  n[X] *  n[Y] + iy *  n[X] + ix;
	jdx = jz * nn[X] * nn[Y] + jy * nn[X] + jx;
	odata.at(jdx) = ndata.at(idx);
      }
    }
  }

  FILE *fo = fopen(of, "wb");
  if (fo == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  fwrite(&odata[0], sizeof odata[0], odata.size(), fo);
  fclose(fo);

  printf("(bovnslice.cpp) odata[osize-1]: %g\n", odata[osize-1]);
  printf("(bovnslice.cpp) odata[      0]: %g\n", odata[0]);
}
