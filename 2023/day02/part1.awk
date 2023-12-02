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
    possible = 1
    for (i = 1; i <= NF; i++) {
        if (color($i, "red") > 12 || color($i, "green") > 13 || color($i, "blue") > 14) {
            possible = 0
        }
    }
    if (possible == 1) {
        sum += NR
    }
}
