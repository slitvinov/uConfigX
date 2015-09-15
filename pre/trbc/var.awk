#!/usr/bin/awk -f

NR == 1 {
  min = max = $1
}

NF {
    n++
    x = $1
    sum  += x
    sum2 += x^2
    min = x < min ? x : min
    max = x > max ? x : max
}

END {
    E = sum/n
    E2 = sum2/n
    var = E2 - E^2

    printf "#%12s %12s %12s %12s %12s %12s %12s\n",
	"n", "sum", "min", "E", "max", "sqrt(var)/E", "(max-min)/E"
    printf " %12g %12g %12g %12g %12g %12g %12g\n",
	n, sum, min, E, max, sqrt(var)/E, (max-min)/E
}
