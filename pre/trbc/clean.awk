#!/usr/bin/awk -f

{
    sub(/#.*/, "")         # strip comments
}

/^[ \t]*$/ {               # skip empty lines
    next
}

{
    gsub(/\[/, " ")
    gsub(/\]/, " ")

    gsub(/[ \t]+$/, "")
    gsub(/^[ \t]+/, "")    
    gsub(/[ \t]+/, " ") # collapse whitespaces

    # get rid of point1, bond1, face1
    gsub(/point[0-9]*/, "point", $1)
    gsub(/bond[0-9]*/ , "bond" , $1)
    gsub(/face[0-9]*/ , "face" , $1)
}

{
    print
}
