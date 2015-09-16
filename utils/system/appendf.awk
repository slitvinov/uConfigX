#!/usr/bin/awk -f

# Add $1 to the content of the input file

BEGIN {
    prefix = ARGV[1]
    ARGV[1] = ""
}

{
    printf "%s", sep prefix $0
    sep = " "
}
