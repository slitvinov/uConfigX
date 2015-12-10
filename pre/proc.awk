#!/usr/bin/awk -f

# How many processes to use?

BEGIN {
    sc=1/2
    Lx=2240*sc
    Ly=520*sc
    Lz=56*sc

    nden=4 # DPD particles number density

    Npmax=5e6
    Npmin=1e5

    lmin=5

    mins = 1e20
    rm=15
    for (rx=1; rx<=rm; rx++)
	for (ry=1; ry<=rm; ry++)
	    for (rz=1; rz<=rm; rz++) {
		if (!good()) continue
		if ((s = score()) > mins) continue
		mins = s
		opt["rx"]=rx; opt["ry"]=ry; opt["rz"]=rz
		opt["lx"]=lx; opt["ly"]=ly; opt["lz"]=lz
	    }

    if (!opt["rx"]) {
	printf "(proc.awk)(ERROR) cannot distribute job between processors\n"
	exit 2
    }

    print "r:", opt["rx"], opt["ry"], opt["rz"]
    print "l:", opt["lx"], opt["ly"], opt["lz"]
}

function divp(A, B) {return A % B == 0} # is `A' divisible by `B'?

function req_lmin() {                   # check the minimum size
    if (lx<lmin)         return 0
    if (ly<lmin)         return 0
    if (lz<lmin)         return 0
    return 1
}

function req_div() {                    # check if subdomain size is divisible by 4
    if (!divp(Lx, 4*rx)) return 0
    if (!divp(Ly, 4*ry)) return 0
    if (!divp(Lz, 4*rz)) return 0
    return 1
}

function req_np() {                     # limit the number of DPD particles in subdomain
    if (Np > Npmax) return 0
    if (Np < Npmin) return 0
    return 1
}

function good() {
    if (!req_div()) return 0
    lx = Lx/rx; ly = Ly/ry; lz = Lz/rz
    
    if (!req_lmin()) return 0
    
    V  = lx*ly*lz
    Np = V*nden
    if (!req_np()) return 0
    
    return 1
}

function swap(a, i, j,    tmp) { tmp=a[i]; a[i]=a[j]; a[j]=tmp}
function sort3(e1, e2, e3, a) {  # sort 3 numbers
    a[1]=e1; a[2]=e2; a[3]=e3
    if (a[1]>a[3])
	swap(a, 1, 3)
    else if (a[1]>a[2])
	swap(a, 1, 2)
    else if (a[2]>a[3])
	swap(a, 2, 3)
}

function score(    a) {
    sort3(lx, ly, lz, a)
    return a[3]/a[1] + a[2]/a[1] # ad hoc "imbalance score"
}
