/* Slice BOV data file

Usage:
./bovnslice <input data file> <output data file> \
            <nxl> <nyl> <nzl>                    \
            <sxl> <syl> <szl> <sxh> <syh> <szh>

<nx> <ny> <nz>: old sizes

Keep only points (includeing both ends):
[sxl:sxh][syl:syh][szl:szh]

Note: assumes one component float data

*/

#include <cstdio>
#include <cstdlib>
#include <vector>

typedef float btype; // type in BOV file

enum DIM {X, Y, Z};

int main(int /* argc */, char *argv[]) {
  using namespace std;
  char* fn = argv[1];
  char* of = argv[2];

  printf("fn, of: %s %s\n", fn , of);

  int n[3];
  n[X] = atoi(argv[3]);
  n[Y] = atoi(argv[4]);
  n[Z] = atoi(argv[5]);  
  printf("nx ny nz: %d %d %d\n", n[X], n[Y], n[Z]);

  int sl[3];
  sl[X] = atoi(argv[6]);
  sl[Y] = atoi(argv[7]);
  sl[Z] = atoi(argv[8]);

  int sh[3];
  sh[X] = atoi(argv[9]);
  sh[Y] = atoi(argv[10]);
  sh[Z] = atoi(argv[11]);
  printf("sxl syl szl: %d %d %d\n", sl[X], sl[Y], sl[Z]);
  printf("sxh syh szh: %d %d %d\n", sh[X], sh[Y], sh[Z]);

  int nsize = n[X] * n[Y] * n[Z];
  int nn[3];
  nn[X] = sh[X] - sl[X];
  nn[Y] = sh[Y] - sl[Y];
  nn[Z] = sh[Z] - sl[Z];
  printf("nnx nny nnz: %d %d %d\n", nn[X], nn[Y], nn[Z]);
  
  int osize = nn[X] * nn[Y] * nn[Z];
  
  FILE *fp = fopen(fn, "r");

  vector<btype> ndata(nsize);
  fread(&ndata[0], sizeof ndata[0], ndata.size(), fp);
  fclose(fp);

  vector <btype> odata(osize, 42.0);

  int ix, iy, iz; /* old index */
  int jx, jy, jz; /* new index */
  int idx, jdx;

  for (iz=sl[Z]; iz<sh[Z]; iz++) {
    jz = iz - sl[Z];
    for (iy=sl[Y]; iy<sh[Y]; iy++) {
      jy = iy - sl[Y];
      for (ix=sl[X]; ix<sh[X]; ix++) {
	jx = ix - sl[X];
	idx = iz *  n[X] *  n[Y] + iy *  n[X] + ix;
	jdx = jz * nn[X] * nn[Y] + jy * nn[X] + jx;
	odata.at(jdx) = ndata.at(idx);
      }
    }
  }

  FILE *fo = fopen(of, "wb");
  fwrite(&odata[0], sizeof odata[0], odata.size(), fo);
  fclose(fo);

  printf("odata[osize-1]: %g\n", odata[osize-1]);
  printf("odata[      0]: %g\n", odata[0]);
}
