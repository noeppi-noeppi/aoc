#!/usr/bin/env tclsh

puts -nonewline "Enter amount of lines: "
flush stdout

set length [gets stdin]
set width -1

puts "Enter input:"

for {set i 0} {$i < $length} {incr i} {
    set lines($i) [gets stdin]
    if {$width < 0} {
        set width [string length $lines($i)]
    } elseif {$width != [string length $lines($i)]} {
        puts "Length of input lines mismatch."
        exit 1
    }
}

set line 0
set hor_idx 0
set trees 0
while {$line < $length} {
    while {$hor_idx >= $width} {
        incr hor_idx [expr -1 * $width]
    }
    if {[string compare [string range $lines($line) $hor_idx $hor_idx] "#"] == 0} {
        incr trees
    }
    incr hor_idx 3
    incr line
}

puts -nonewline "Amount of trees: "
puts $trees
