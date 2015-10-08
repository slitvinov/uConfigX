# generate initial uConfigX directory strucutre from a template
# `getdir.templ'
# Usage (from <gitroot>):
# awk -f utils/system/getdir.awk utils/system/getdir.templ

BEGIN {
    fs=":"
    eofstat = 1
    file    = ARGV[1]
    ARGV[1] = ""   # read fiel implicitly
    mch[">"]=mch["!"]=1

    main()
}

function psystem(cmd, rc) {
    print "(dd.awk) executing: " cmd
    rc = system(cmd)
    return rc
}


function nextline() {
    if (eofstat <=0)
	return 0
    if (ungot) {
	line = ungotline
	ungot = 0
	return 1
    }
    return eofstat = (getline line < file)
}

function unget()  { ungotline = line; ungot = 1 }

function trim_b(s) {
    sub("^[ \t]*", "", s)
    return s
}

function trim_e(s) {
    sub("[ \t]*$", "", s)
    return s
}

function trim(s) {
    return trim_e(trim_b(s))
}

function main() {
    while (nextline() > 0) {
	sub(/^\#.*/, "", line) # strip comments at the beginning
	if (!line)
	    continue
	split(line, arr, fs)
	f=trim(arr[1])
	text=trim(arr[2])
	"dirname " f | getline d
	psystem("mkdir -p " d)
	if (text)
	    print text > f

	while (1) {
	    nextline()
	    if (eofstat <= 0) break
	    fst = substr(line, 1, 1)
	    in_mch = (fst in mch)
	    if (!(in_mch)) {
		unget()
		break
	    }

	    if         (fst == ">") {
		text = trim(line)
		sub("^>", "", text)
		print text > f
	    } else if (fst == "!") {
		text = trim(line)		
		sub("^!", "", text)
		cmd = text " " f
		psystem(cmd)
	    }
	}
    }
}
