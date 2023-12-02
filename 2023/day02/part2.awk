function color(input, name) {
    split(input, parts, ", *")
    for (j in parts) {
        if (substr(parts[j], length(parts[j]) - length(name) + 1) == name) {
            return substr(parts[j], 1, length(parts[j]) - length(name))+0
        }
    }
    return 0
}

BEGIN {FS = "[:;]" }
END { print sum }

{
    red = 0
    green = 0
    blue = 0
    for (i = 1; i <= NF; i++) {
        if (color($i, "red") > red) { red = color($i, "red") }
        if (color($i, "green") > green) { green = color($i, "green") }
        if (color($i, "blue") > blue) { blue = color($i, "blue") }
    }
    sum += red * green * blue
}
