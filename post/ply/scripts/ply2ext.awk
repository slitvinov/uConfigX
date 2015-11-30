#!/usr/bin/awk -f

# Extend domain using periodic images
# Usage:
#  box='-v   xl=0  -v  yl=0  -v  zl=0  -v  xh=72  -v  yh=48  -v  zh=24'
# ebox='-v  exl=-4 -v eyl=-4 -v ezl=-4 -v exh=76  -v eyh=52  -v ezh=28'
# ./ply2ext.awk $box $ext

#  box='-v   xl=-1  -v  yl=-1  -v  zl=-1  -v  xh=1  -v  yh=1  -v  zh=1'
# ebox='-v  exl=-1.5 -v eyl=-1.5 -v ezl=-1.5 -v exh=3.0  -v eyh=1.5  -v ezh=1.5'
# ./ply2ext.awk -v Nv=12 $box $ebox ../test_data/icosahedron.ply

function req_var(v, n) {
    if (length(v)) return
    printf "(ply2ext.awk) `%s' should be given as a parameter (-v %s=<value>)\n",
	n, n
    exit 2
}

function read_header(    ih) { # sets `nv', `nf', and `nlh'
    while (getline < fn > 0 && $0 != "end_header" ) {
	header[++ih] = $0
	if ($1 == "element" && $2 == "vertex") nv = $3
	if ($1 == "element" && $2 == "face"  ) nf = $3
    }
    header[++ih] = $0
    nlh = ih # number of lines in a header
}

function print_header(    ih) { # uses `nv' and `nf'
    for (ih=1; ih<=nlh; ih++) {
	split(header[ih], arr)
	if (arr[1] == "element" && arr[2] == "vertex")
	    print "element vertex " nv_img
	else if (arr[1] == "element" && arr[2] == "face"  )
	    print "element face " nf_img
	else if (arr[1] == "property" && arr[3]~/^[uvw]$/)
	    ;
	    # do not put velocity in output
	else
	    print header[ih]
    }
}

function iv2lv(iv, iobj) {return iv - (iobj-1)*Nv}
function lv2iv(lv, iobj) {return lv + (iobj-1)*Nv}

function read_vert(    iv, lv, iobj, x, y, z) { # uses `nv', sets `vert'
    for (iv=1; iv<=nv; iv++) {
	iobj = iv2obj(iv)
	lv   = iv2lv(iv, iobj)
	getline < fn
	x = $1; y = $2; z = $3
	vert[iobj,lv] = x " " y " " z
    }
}

function read_face(    ifa, id1, id2, id3) {
    for (ifa=1; ifa<=nf; ifa++) {
	getline < fn
	id1 = $2; id2 = $3; id3 = $4
	face[ifa] = id1 " " id2 " " id3
    }
}

function decode_face(f,    arr) { # sets `id1', `id2', `id3'
    split(f, arr)
    id1 = arr[1]; id2 = arr[2]; id3 = arr[3]
}

function decode_vert(v,    arr) { # sets `x', `y', `z'
    split(v, arr)
    x = arr[1]; y = arr[2]; z = arr[3]
}

function iv2obj(iv) { # return object number
    return int((iv-1)/Nv)+1
}

function create_image(i) { # sets `xi', `yi', `zi'
    xi = x + Lx*xs[i]; yi = y + Ly*ys[i]; zi = z + Lz*zs[i]
}

function in_ext(x, y, z) { # is point inside extended domain?
    return \
	x >= exl && x<= exh &&
	y >= eyl && y<= eyh &&
	z >= ezl && z<= ezh
}

function build_ptbl(   lv, iv, is, iobj) { # build "periodic image table"
    for (iv=1; iv<=nv; iv++) {
	iobj = iv2obj(iv)
	lv   = iv2lv(iv, iobj)
	decode_vert(vert[iobj,lv])
	ptbl[iobj,1] = 1 # the original
	for (is=2; is<=ns; is++) { # images
	    create_image(is)
	    ptbl[iobj, is] = in_ext(xi, yi, zi)
	}
    }
}

function ouptut_vert(x, y, z,    sep) {
    sep = nv_img ? "\n" : ""
    block_vert = block_vert sep x " " y " " z
    nv_img++
}

function print_vert0(iobj, is,    lv) { # originals
    for (lv=1; lv<=Nv; lv++) {
	decode_vert(vert[iobj, lv])
	create_image(is)
	ouptut_vert(xi, yi, zi)
    }
}

function print_vert(   iv, nobj0, iobj) { # sets `stbl': shift table
    nobj0 = iv2obj(nv)

    for (iobj=1; iobj<=nobj0; iobj++) {# print original
	print_vert0(iobj, 1)
	stbl[iobj, 1] = 0 # shift vertices ids relative to original
    }

    nobj  = nobj0
    for (is=2; is<=ns; is++)          # print images
	for (iobj=1; iobj<=nobj0; iobj++) {
	    if (!ptbl[iobj, is]) continue
	    nobj++
	    print "nobj: ", nobj > "/dev/stderr"
	    stbl[iobj, is] = (nobj - iobj)*Nv
	    print_vert0(iobj, is)
	}
}

function output_face(id1, id2, id3) {
    sep = nf_img ? "\n" : ""
    block_face = block_face sep 3 " " id1 " " id2 " " id3
    nf_img++
}

function print_face(    ifa, nobj0, iobj) { # updates `nf'
    for (ifa=1; ifa<=nf; ifa++) {
	decode_face(face[ifa])
	iobj = iv2obj(id1)
	for (is=1; is<=ns; is++) { # images
	    if (!ptbl[iobj, is]) continue
	    shift = stbl[iobj,is]
	    nfi++
	    output_face(id1+shift, id2+shift, id3+shift)
	}
    }
}

BEGIN {
    # box dimensions
    req_var(xl, "xl"); req_var(yl, "yl"); req_var(zl, "zl")
    req_var(xh, "xh"); req_var(yh, "yh"); req_var(zh, "zh")

    # extended box dimensions
    req_var(exl, "exl"); req_var(eyl, "eyl"); req_var(ezl, "ezl")
    req_var(exh, "exh"); req_var(eyh, "eyh"); req_var(ezh, "ezh")

    # number of vertices in one object
    req_var(Nv, "Nv")

    Lx = xh - xl; Ly = yh - yl; Lz = zh - zl

    # In maxima:
    # (%i1) L: listify(cartesian_product ({-1, 0, 1}, {-1, 0, 1}, {-1, 0, 1}))$
    # (%i2) printf(true, "\"~{~2d ~}\"~%", map('first, L))$
    # (%i3) printf(true, "\"~{~2d ~}\"~%", map('second, L))$
    # (%i4) printf(true, "\"~{~2d ~}\"~%", map('third, L))$
    xs_string = "0 -1 -1 -1 -1 -1 -1 -1 -1 -1  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1 "
    ys_string = "0 -1 -1 -1  0  0  0  1  1  1 -1 -1 -1  0  0  1  1  1 -1 -1 -1  0  0  0  1  1  1 "
    zs_string = "0 -1  0  1 -1  0  1 -1  0  1 -1  0  1 -1  1 -1  0  1 -1  0  1 -1  0  1 -1  0  1 "
    ns=split(xs_string, xs)
    ns=split(ys_string, ys)
    ns=split(zs_string, zs)

    if (ARGC < 2)
	fn = "-" # use `stdin'
    else {
	fn = ARGV[1] # read file implicitly
	ARGV[1] = ""
    }

    read_header()
    read_vert()
    read_face()

    build_ptbl()

    print_vert()
    print_face()

    print_header()
    print block_vert
    print block_face
}
