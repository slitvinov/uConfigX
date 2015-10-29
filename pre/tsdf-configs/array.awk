#!/usr/bin/awk -f

function init() {
    N_obst_x = nx
    N_obst_y = ny
    l_element = lx
}

function sc(d) {
    return d/scale
}

function inside_domain(x0, y0) {
    if (x0+obj_rx<xlo) return False
    if (x0-obj_rx>xhi) return False
    if (y0+obj_ry<ylo) return False
    if (y0-obj_ry>yhi) return False
    return True
}

function ij2x(i, j) {
    return 1.0/2.0*l_element_x + j*(l_element_x - shift_x) + i*l_element_x
}

function ij2y(i, j) {
    return 1.0/2.0*l_element_y + j*l_element_y
}

function pre() {
    printf "extent     %g %g %g\n", sc(Lx), sc(Ly), sc(Lz)
    printf "N          %d\n", Nx
    printf "obj_margin %g\n",      sc(obj_margin)
}

function gen_ellipse(x0, y0) {
    x0 = sc(x0); y0 = sc(y0); z0 = sc(z0); obj_rx = sc(obj_rx); obj_ry = sc(obj_ry)
    printf "ellipse axis XY point %g %g %g radius %g %g angle 0\n", x0, y0, z0, obj_rx, obj_ry
}

function gen_egg(x0, y0) {
    x0 = sc(x0); y0 = sc(y0); z0 = sc(z0); obj_rx = sc(obj_rx); obj_ry = sc(obj_ry)
    printf "egg axis XY point %g %g %g radius %g %g angle 0 eggness 0.5\n", x0, y0, z0, obj_rx, obj_ry
}

function gen_cylinder(x0, y0) {
    printf "cylinder axis 0 0 1 point %g %g %g radius %g\n", sc(x0), sc(y0), sc(z0), sc(obj_rx)
}

BEGIN {
    init()
    
    False = 0
    True  = 1

    l_element_x = l_element_y = l_element_z = l_element

    obj_rx  = Rx
    obj_ry  = Ry

    shift_x = l_element_x/N_obst_y

    xlo = ylo = 0
    xhi = l_element_x*N_obst_x
    yhi = l_element_y*N_obst_y

    Lx  = xhi - xlo
    Ly  = yhi - ylo
    Lz  = l_element_z

    Nx  = 2*l_element
    
    zc = Lz/2
    
    scale = 1.0
    obj_margin = 3.0*scale


    pre()
    for (i=-100; i<=100; i++) {
	for (j=-100; j<=100; j++) {
	    x0 = ij2x(i, j)
	    y0 = ij2y(i, j)
	    if (inside_domain(x0, y0))
		gen_egg(x0, y0)
	}
    }
}
