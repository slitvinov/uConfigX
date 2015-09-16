#!/usr/bin/awk -f

# Add $1 to the content of the input file

BEGIN {
    # pass prefix as a variable
}

NF {
    printf "%s", sep prefix $0
    sep = " "
}
