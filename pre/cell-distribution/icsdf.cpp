#include <vector>
#include <limits>
#include <cstdio>
#include <cstdlib>
#include <cmath>

/* example

make
./icsdf ~/ych.dat ~/rbcs-ic.txt /dev/stdout  > wall.txt
../trbc/placeunref.awk wall.txt ../trbc/examples/rbc.org.unref     | ur unref2vtk.awk > v.vtk

*/


typedef float real;
const real cell_wall_dist = 2.0;
bool is_banned(real wall, float x, float y, float z) {
  return fabs(wall) > cell_wall_dist ? true : false;
}

int NX, NY, NZ; // grid size
real xextent, yextent, zextent; // domain
real spx, spy, spz;             // grid spacing
std::vector<real> sdf_data;
std::vector<bool> ban_data;

real xd, yd, zd; // dummy center of a cell
real xc, yc, zc; // real  center of a cell

real M[4][4];

void usage() {
  printf("OVERVIEW: convert sdf file format to xml vtk (vti)\n");
  printf("USAGE: icsdf <input sdf file> <output vti file>\n");
}

float i2x (int i)  {return spx*i;}
float i2y (int i)  {return spy*i;}
float i2z (int i)  {return spz*i;}

float d2lin(int i, int j, int k) {return k*(NY*NX) + j*NX + i;};

int wx(int i)     {return \
    i<0   ? wx(i+NX) :
    i>=NX ? wx(i-NX) :
    i;}

int wy(int i)     {return \
    i<0   ? wy(i+NY) :
    i>=NY ? wy(i-NY) :
    i;}

int wz(int i)     {return \
    i<0   ? wz(i+NZ) :
    i>=NZ ? wz(i-NZ) :
    i;}

int x2i (real r)  {return wx(int(r/spx));}
int y2i (real r)  {return wy(int(r/spy));}
int z2i (real r)  {return wz(int(r/spz));}

void read_sdf(const char* fn) {
  fprintf(stderr, "(icsdf) Reading file %s\n", fn);
  FILE * f = fopen(fn, "r");
  if (f == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  fscanf(f, "%f %f %f\n", &xextent, &yextent, &zextent);
  fscanf(f, "%d %d %d\n", &NX, &NY, &NZ);
  fprintf(stderr, "(icsdf) Extent: [%g, %g, %g]. Grid size: [%d, %d, %d]\n",
	 xextent, yextent, zextent, NX, NY, NZ);

  spx = xextent/(float)(NX-1);
  spy = yextent/(float)(NY-1);
  spz = zextent/(float)(NZ-1);

  sdf_data.resize(NX*NY*NZ);
  fread(&sdf_data[0], sizeof(real), NX*NY*NZ, f);
  fclose(f);
}

void fill_ban() {
  ban_data.resize(NX*NY*NZ);
  for (int i = 0; i < NX; i++) {
    float x = i2x(i);
    for (int j = 0; j < NY; j++) {
      float y = i2y(j);
      for (int k = 0; k < NZ; k++) {
	float z = i2z(k);
	int idx = d2lin(i, j, k);
	float wall  = sdf_data[idx];
	ban_data[idx] = is_banned(wall, x, y, z);
      }
    }
  }
}

bool nn(FILE* f, real &e) // next number
{
  int rc = fscanf(f, "%e", &e);
  return  rc == 1;
}

bool read_cell(FILE* f) {
  bool rc = nn(f, xd);
  if (!rc) return rc;
  nn(f, yd); nn(f, zd);
  for (int i=0; i<4; i++)
    for (int j=0; j<4; j++)
      nn(f, M[i][j]);

  xc = M[0][3]; yc = M[1][3]; zc = M[2][3];
  return true;
}

void write_cell(FILE* v) {
  fprintf(v, "%.6g %.6g %.6g\n", xd, yd, zd);
  for (int i=0; i<4; i++) {
    for (int j=0; j<4; j++)
      fprintf(v, "%.6g ", M[i][j]);
    fprintf(v, "\n");
  }
}

int main(int argc, char ** argv) {
  read_sdf(argv[1]);
  fill_ban();

  const char* fn = argv[2];
  fprintf(stderr, "(icsdf) Reading file %s\n", fn);
  FILE * f = fopen(fn, "r");
  if (f == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  const char* op = argv[3];
  fprintf(stderr, "(icsdf) Writing to file %s\n", op);
  FILE * v = fopen(op, "w");
  if (v == NULL ) {
    perror("Error");
    exit(EXIT_FAILURE);
  }

  real e;
  while (read_cell(f)) {
    int ic = x2i(xc); int jc = y2i(yc); int kc = z2i(zc);
    int idx = d2lin(ic, jc, kc);
    if (!ban_data[idx])
      write_cell(v);
  }
    
  fclose(f);
  fclose(v);
}
