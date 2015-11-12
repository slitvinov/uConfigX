#!/usr/bin/awk -f

# Returns statistics for the RBC or sphere model for given number of
# vertices (`Nv')
# See also: DOE/transform.daint

function req_var(v, n) {
    if (length(v)==0) {
	printf "(ply2ncell.awk)(ERROR) `%s' should be given as a parameter (-v %s=<value>)\n",
	    n, n
	exit 2
    }
}

function asin(x) {return atan2(x, sqrt(abs(1-x*x))) }
function pi()    {return 2*asin(1)}
function abs(x)  {return x<0?x*-1:x}

function a2v_sphere(A,  V0, A0) { # area to volume for spehre
      V0 = 4/3*pi()
      A0 = 4*pi()
      return (A^(3/2)*V0)/A0^(3/2)
}

function a2v_rbc(A,  V0, A0) { # area to volume for RBC
      V0 = 91
      A0 = 135 # page 54 Fedosov2010
      return (A^(3/2)*V0)/A0^(3/2)
}

function a2v(A) {
    if (cshape == SPHERE)
	return a2v_sphere(A)
    elseif  (cshape == RBC)
        return a2v_rbc(A)
}

function a2r_sphere(A,  R0, A0) { # area to radius for spehre
      R0 = 1
      A0 = 4*pi()
      return (A^(1/2)*R0)/A0^(1/2)
}

function a2r_rbc(A,  R0, A0) { # area to radius for RBC
      R0 = 7.82
      A0 = 135
      return (A^(1/2)*R0)/A0^(1/2)
}

function a2r(A) {
    if (cshape == SPHERE)
	return a2r_sphere(A)
    elseif  (cshape == RBC)
        return a2r_rbc(A)
}

function update(nd, l0, dx, Nt) { # sets `totArea0' and `totVolume0'
    nd    = 4                               # DPD number density
    dx    = 1/nd^(1/3)                      # DPD particles spacing
    l0     = 0.89*dx                        # 0.89 for uDeviceX
    Nt    = 2*Nv - 4                        # number of triangles
    totArea0 = Nt * sqrt(3)/4 * l0^2        # (3.30) in Fedosov2010
    totVolume0 = a2v(totArea0)
    R0         = a2r(totArea0)
}

BEGIN {
    req_var(Nv, "Nv")
    
    SPHERE = 0; RBC = 1                     # shapes

    cshape = SPHERE; update()
    print "SPHERE\t", R0, totArea0, totVolume0
    
    cshape = RBC; update()
    print "RBC\t",    R0, totArea0, totVolume0
}
