/* Slice BOV data file

Usage:
./transformbov <input data file> <output data file>  \
                <nxl> <nyl> <nzl>                    \
                <sc>

Multiple data in <input data file> by `sc'

Note: assumes one component float data

*/

#include <cstdio>
#include <cstdlib>
#include <vector>

typedef float btype; // type in BOV file

enum DIM {X, Y, Z};

int main(int argc, char *argv[]) {
  if (argc != 7) {
    fprintf(stderr, "(transformbov.cpp)(ERROR) not enough argumetns\n");
    exit(2);
  }

  using namespace std;
  char* fn = argv[1];
  char* of = argv[2];
  printf("(transformbov.cpp) fn, of: %s %s\n", fn , of);  

  int n[3];
  n[X] = atoi(argv[3]);
  n[Y] = atoi(argv[4]);
  n[Z] = atoi(argv[5]);  
  printf("(transformbov.cpp) nx ny nz: %d %d %d\n", n[X], n[Y], n[Z]);

  float sc = atof(argv[6]);
  int nsize = n[X] * n[Y] * n[Z];
  
  FILE *fp = fopen(fn, "r");
  if (fp == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  vector<btype> ndata(nsize);
  fread(&ndata[0], sizeof ndata[0], ndata.size(), fp);
  fclose(fp);
  vector <btype> odata(nsize);

  for (int idx=0; idx<nsize; idx++)
    odata[idx] = sc*ndata[idx];

  FILE *fo = fopen(of, "wb");
  if (fo == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  fwrite(&odata[0], sizeof odata[0], odata.size(), fo);
  fclose(fo);
}
