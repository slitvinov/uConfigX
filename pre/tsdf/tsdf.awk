#!/usr/bin/awk -f

# tsdf - tiny sdf generator
#   usage: ./tsdf.awk def_file sdf_file [vtk_file]
# TEST: tsdf1
# ./tsdf.awk examples/ywall1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf2
# ./tsdf.awk examples/ywall2.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf3
# ./tsdf.awk examples/sphere1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf4
# ./tsdf.awk examples/sphere2.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf5
# ./tsdf.awk examples/cylinder1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf6
# ./tsdf.awk examples/cylinder2.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf7
# ./tsdf.awk examples/out_sphere1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf8
# ./tsdf.awk examples/out_cylinder1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf9
# ./tsdf.awk examples/channel1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf10
# ./tsdf.awk examples/block1.tsdf sdf.dat sdf.out.vti
#
# TEST: tsdf11
# ./tsdf.awk examples/block2.tsdf sdf.dat sdf.out.vti

function randint(n) { return int(rand()*n)+1 }

function init() {
    "us processor.tmp.cpp" | getline processor_file
    "us sdf2vtk.cpp"       | getline SDF2VTK

    CXX="g++"
    CPPFLAGS="-O2 -g"

    if (ARGC<3) esage()

    sdf_file = ARGV[2]
    ARGV[2] = ""

    vtk_file = ARGV[3]
    ARGV[3] = ""

    TMPDIR  = "/tmp/tsdf." randint(100000)
    wsystem("mkdir -p " TMPDIR)
}

function wsystem(cmd) {
    printf "(tsdf.awk) : running %s\n", cmd
    system(cmd)
}

function esage() {
    usage()
    EXIT_FAILURE = 1
    exit
}

function usage () {
    printf "tsdf - tiny sdf generator\n"
    printf "   usage: ./tsdf.awk def_file sdf_file [vtk_file]\n"
}

function gensp(i) {
    return sprintf ("%" i "s", " ")
}

function psub(r, t) { gsub("%" r "%", t, processor) }

function csub(r, t) { gsub("//%" r "%", t, processor) } # subst in comments

{
    sub(/#.*/, "")         # strip comments
}

!NF {
    # skip empty lines
    next
}

$1=="extent" {
    xextent=$2; yextent=$3; zextent=$4
    psub("xextent", xextent)
    psub("yextent", yextent)
    psub("zextent", zextent)    
}

$1=="N" {
    NX = $2
    # if not given guess it from extents
    NY = NF < 3 ? yextent * (NX / xextent) : $3
    NZ = NF < 4 ? zextent * (NX / xextent) : $4

    psub("NX", NX); psub("NY", NY); psub("NZ", NZ);
}

$1=="obj_margin" {
    obj_margin = $2
    psub("OBJ_MARGIN", obj_margin)
}

function format_expr( e,     i, n, ans, tab, sep) {
    n = length(e)
    if (n==1)
	return e[1]

    tab = gensp(18)
    ans = "(\n"
    for (i = 1; i<=n; i++) {
	ans = ans sep tab "  " e[i]
	sep = ",\n"
    }
    ans = ans "\n" tab ")"
    
    return ans
}

function format_line(expr, tab, ans, update_fun) {
    update_fun = VOID_WINS ? "void_wins" : "wall_wins"
    if (INVERT)
	ans = sprintf("s = %s(s, -(%s));", update_fun, expr)
    else
	ans = sprintf("s = %s(s,    %s);", update_fun, expr)
    gsub("\n", "\n" ans)
    return tab ans
}

function expr_plane(     nx, ny, nz, x0, y0, z0,     m, e) {
    x0=$3; y0=$4; z0=$5
    nx=$7;  ny=$8;  nz=$9
    e[++m] = sprintf("nx = %s, ny = %s, nz = %s", nx, ny, nz)
    e[++m] = sprintf("x0 = %s, y0 = %s, z0 = %s", x0, y0, z0)     
    e[++m] = "n_abs = sqrt(nz*nz+ny*ny+nx*nx)"
    e[++m] = "(nz*(z0-z))/n_abs+(ny*(y0-y))/n_abs+(nx*(x0-x))/n_abs"
    return format_expr(e)
}

function expr_cylinder(     nx, ny, nz, xp, yp, zp, R,     m, e) {
    ax=$3;  ay=$4;  az=$5
    xp=$7;  yp=$8;  zp=$9
    R = $11
    e[++m] = sprintf("ax = %s, ay = %s, az = %s", ax, ay, az)
    e[++m] = sprintf("xp = %s, yp = %s, zp = %s", xp, yp, zp)    
    e[++m] = "a2 = az*az+ay*ay+ax*ax"
    e[++m] = "D = sqrt((z-(az*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2-zp)" \
          "*(z-(az*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2-zp)" \
          "+(y-yp-(ay*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2)" \
          " *(y-yp-(ay*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2)" \
          "+(x-xp-(ax*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2)" \
          " *(x-xp-(ax*(az*(z-zp)+ay*(y-yp)+ax*(x-xp)))/a2))"
    e[++m] = sprintf("%s - D", R)
    return format_expr(e)
}

function expr_sphere(m, xc, yc, zc, R, e) {
    xc = $3; yc=$4; zc=$5; R=$7
    e[++m] = sprintf("r2 = (x-%s)*(x-%s) + (y-%s)*(y-%s) + (z-%s)*(z-%s)", xc, xc, yc, yc, zc, zc)
    e[++m] = sprintf("r0 = sqrt(r2)")
    e[++m] = sprintf("%s - r0", R)
    return format_expr(e)    
}



function expr_block(     xlo, xhi, ylo, yhi, zlo, zhi,     m, e) {
    xlo = $2; xhi=$3
    ylo = $4; yhi=$5
    zlo = $6; zhi=$7
    e[++m] = sprintf("dX2 = sq(de(x, %s, %s)) + sq(di(y, %s, %s)) + sq(di(z, %s, %s))", \
		     xlo, xhi, ylo, yhi, zlo, zhi)
    e[++m] = sprintf("dY2 = sq(di(x, %s, %s)) + sq(de(y, %s, %s)) + sq(di(z, %s, %s))", \
		     xlo, xhi, ylo, yhi, zlo, zhi)
    e[++m] = sprintf("dZ2 = sq(di(x, %s, %s)) + sq(di(y, %s, %s)) + sq(de(z, %s, %s))", \
		     xlo, xhi, ylo, yhi, zlo, zhi)
    e[++m] = "dR2 = min3(dX2, dY2, dZ2)"
    e[++m] = "dR  = sqrt(dR2)"

    e[++m] = sprintf("in_box(x, y, z, %s, %s, %s, %s, %s, %s) ? dR : -dR", \
		     xlo, xhi, ylo, yhi, zlo, zhi)

    return format_expr(e)
}

function add_code_line(line, tab) {
    tab = gensp(8)
    csub("update_sdf", line "\n" tab  "//%update_sdf%")
}

function expr2code(expr) {
    add_code_line(format_line(expr))
}

# decide if we should invert the object
function set_invert() {
    INVERT = (match($1, /!/) == 1)
    if (INVERT)
	sub(/!/, "", $1)
}

{
    set_invert()
}

function set_void_or_wall() {
    VOID_WINS = (match($1, /\|/) == 1)
    if (VOID_WINS)
	sub(/\|/, "", $1)
}

{
    set_void_or_wall()
}

$1 == "plane" {
    expr2code(expr_plane())
}

$1 == "sphere" {
    expr2code(expr_sphere())
}

$1 == "cylinder" {
    expr2code(expr_cylinder())
}

$1 == "block" {
    expr2code(expr_block())
}


BEGIN {
    init()
    # read entire file
    while (getline < processor_file > 0) {
	processor = processor sep $0
	sep = ORS
    }
}

# strip suffix
function ss(s) {
    sub(/\.[^\.]*$/, "", s)
    return s
}

function basename1(s, arr, nn) {
    nn=split(s, arr, "/")
    return arr[nn]
}

function basename(s) {
    return ss(basename1(s))
}

function psystem(s) {
    printf "(tsdf.awk) exec: %s\n", s > "/dev/stderr"
    system(s)
}

# uses variables CXX, CXXFLAGS, TMPDIR
function compile_and_run(f, args,      exec_name, c, r) {
    exec_name = TMPDIR "/" basename(f)
    c = sprintf("%s %s -o %s %s", CXX, CXXFLAGS, exec_name, f)
    psystem(c)
    r = sprintf("%s %s", exec_name, args)
    psystem(r)
}

END {

    if (EXIT_FAILURE)
	exit

    processor_code = sprintf("%s/processor.cpp", TMPDIR)
    printf "%s\n", processor > processor_code
    close(processor_code)

    compile_processor = sprintf("%s %s %s -o %s/processor", CXX, CPPFLAGS, processor_code, TMPDIR)
    wsystem(compile_processor)

    run_cmd     = sprintf("%s/processor %s", TMPDIR, sdf_file)
    wsystem(run_cmd)

    if (vtk_file) {
	compile_sdf2vtk = sprintf("%s %s %s -o %s/sdf2vtk", CXX, CPPFLAGS, SDF2VTK, TMPDIR)
	wsystem(compile_sdf2vtk)
	sdf2vtk_cmd     = sprintf("%s/sdf2vtk %s %s", TMPDIR, sdf_file, vtk_file)
	wsystem(sdf2vtk_cmd)
    }
}
